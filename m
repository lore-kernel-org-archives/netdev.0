From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: br2684 incorrectly handles frames recvd with FCS (by Alex Zeffertt <ajz@cambridgebroadband.com>)
Date: Thu, 08 Jan 2004 11:58:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081658.i08GwdRr017374@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, ajz@cambridgebroadband.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 (and 2.4 as well!)

thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1492  -> 1.1493 
#	    net/atm/br2684.c	1.9     -> 1.10   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/07	chas@relax.cmf.nrl.navy.mil	1.1493
# [ATM]: br2684 incorrectly handles frames recvd with FCS (by Alex Zeffertt <ajz@cambridgebroadband.com>)
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Wed Jan  7 13:23:54 2004
+++ b/net/atm/br2684.c	Wed Jan  7 13:23:54 2004
@@ -437,6 +437,10 @@
 			dev_kfree_skb(skb);
 			return;
 		}
+
+		/* Strip FCS if present */
+		if (skb->len > 7 && skb->data[7] == 0x01)
+			__skb_trim(skb, skb->len - 4);
 	} else {
 		plen = PADLEN + ETH_HLEN;	/* pad, dstmac,srcmac, ethtype */
 		/* first 2 chars should be 0 */
