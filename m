From: John Levon <levon@movementarian.org>
Subject: [PATCH] ATM - fix seqfile compile failure
Date: Fri, 5 Sep 2003 18:51:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905175113.GA40730@compsoc.man.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, shemminger@osdl.org,
   linux-atm-general@lists.sourceforge.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The recent conversion to seq_file breaks CONFIG_ATM_BR2684_IPFILTER
compile. 

I have absolutely no idea what the original author was attempting to
achieve with the "pos" thing, btw ... *shrug*

Entirely untested.

regards
john


diff -Naurp -X dontdiff linux-cvs/net/atm/br2684.c linux-fixes/net/atm/br2684.c
--- linux-cvs/net/atm/br2684.c	2003-09-05 07:06:15.000000000 +0100
+++ linux-fixes/net/atm/br2684.c	2003-09-05 18:55:15.000000000 +0100
@@ -732,8 +732,8 @@ static int br2684_seq_show(struct seq_fi
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 #define b1(var, byte)	((u8 *) &brvcc->filter.var)[byte]
 #define bs(var)		b1(var, 0), b1(var, 1), b1(var, 2), b1(var, 3)
-			if (brvcc->filter.netmask != 0 && pos-- == 0)
-				return sprintf(buf, "    filter=%d.%d.%d.%d/"
+			if (brvcc->filter.netmask != 0)
+				seq_printf(seq, "    filter=%d.%d.%d.%d/"
 				    "%d.%d.%d.%d\n", bs(prefix), bs(netmask));
 #undef bs
 #undef b1
