From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] ipconfig invokes undefined behaviour
Date: Sun, 6 Feb 2005 04:47:44 +0000
Message-ID: <20050206044744.GO20386@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


strcpy is undefined if src and dest overlap.  That's clearly possible
here with a sufficiently deep path on the server.  Use memmove instead.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: ./net/ipv4/ipconfig.c
===================================================================
RCS file: /var/cvs/linux-2.6/net/ipv4/ipconfig.c,v
retrieving revision 1.12
diff -u -p -r1.12 ipconfig.c
--- ./net/ipv4/ipconfig.c	22 Jan 2005 15:00:01 -0000	1.12
+++ ./net/ipv4/ipconfig.c	6 Feb 2005 04:41:30 -0000
@@ -1232,7 +1232,7 @@ u32 __init root_nfs_parse_addr(char *nam
 		if (*cp == ':')
 			*cp++ = '\0';
 		addr = in_aton(name);
-		strcpy(name, cp);
+		memmove(name, cp, strlen(cp) + 1);
 	} else
 		addr = INADDR_NONE;
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
