From: Michal Ludvig <mludvig@suse.cz>
Subject: [PATCH] rtnetlink & address family problem
Date: Fri, 03 Dec 2004 18:43:16 +0100
Message-ID: <41B0A5B4.6060108@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020005070601050006080808"
Cc: netdev@oss.sgi.com, Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020005070601050006080808
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit

Hi,

running 'ip -6 addr flush dev eth0' on a kernel without IPv6 support
flushes *all* addresses from the interface, even those IPv4 ones,
because the unsupported protocol is substituted by PF_UNSPEC.
IMHO it should better return with an error EAFNOSUPPORT.

Attached patch fixes it. Please apply.

BTW Credits to Jan Kara <jack@suse.cz> for discovering and analysing
this bug.

Michal Ludvig
-- 
SUSE Labs                    mludvig@suse.cz
(+420) 296.542.396        http://www.suse.cz
Personal homepage http://www.logix.cz/michal

--------------020005070601050006080808
Content-Type: text/plain;
 name="rtnetlink-family.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rtnetlink-family.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/03 18:06:31+01:00 michal@logix.cz 
#   Return EAFNOSUPPORT if requested operation on unsupported family.
#   
#   Signed-off-by: Michal Ludvig <michal@logix.cz>
# 
# net/core/rtnetlink.c
#   2004/12/03 18:05:49+01:00 michal@logix.cz +4 -2
#   Return EAFNOSUPPORT if requested operation on unsupported family.
# 
diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	2004-12-03 18:30:33 +01:00
+++ b/net/core/rtnetlink.c	2004-12-03 18:30:33 +01:00
@@ -477,8 +477,10 @@
 	}
 
 	link_tab = rtnetlink_links[family];
-	if (link_tab == NULL)
-		link_tab = rtnetlink_links[PF_UNSPEC];
+	if (link_tab == NULL) {
+		*errp = -EAFNOSUPPORT;
+		return -1;
+	}
 	link = &link_tab[type];
 
 	sz_idx = type>>2;

--------------020005070601050006080808--
