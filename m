From: Roger Luethi <rl@hellgate.ch>
Subject: [2/3][PATCH 2.6] netdrivers: fix mc_filter on big-endian arch
Date: Sun, 6 Jun 2004 18:53:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040606165336.GA13840@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This untested patch fixes hardware mc filters for tulip_core, winbond,
and atp. Hopefully :-).

Please review and test.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- 2.6-bk/drivers/net/tulip/winbond-840.c.orig	2004-06-06 18:03:51.502473098 +0200
+++ 2.6-bk/drivers/net/tulip/winbond-840.c	2004-06-06 18:04:18.807205433 +0200
@@ -1439,7 +1439,7 @@
 			 i++, mclist = mclist->next) {
 			int filterbit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
 			filterbit &= 0x3f;
-			mc_filter[filterbit >> 5] |= cpu_to_le32(1 << (filterbit & 31));
+			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 		}
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	}
--- 2.6-bk/drivers/net/tulip/tulip_core.c.orig	2004-06-06 18:03:46.319283616 +0200
+++ 2.6-bk/drivers/net/tulip/tulip_core.c	2004-06-06 18:04:36.263478849 +0200
@@ -1059,7 +1059,7 @@
 				else
 					filterbit = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 				filterbit &= 0x3f;
-				mc_filter[filterbit >> 5] |= cpu_to_le32(1 << (filterbit & 31));
+				mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 				if (tulip_debug > 2) {
 					printk(KERN_INFO "%s: Added filter for %2.2x:%2.2x:%2.2x:"
 						   "%2.2x:%2.2x:%2.2x  %8.8x bit %d.\n", dev->name,
--- 2.6-bk/drivers/net/atp.c.orig	2004-06-06 18:03:34.351155626 +0200
+++ 2.6-bk/drivers/net/atp.c	2004-06-06 18:04:55.176526236 +0200
@@ -909,7 +909,7 @@
 			 i++, mclist = mclist->next)
 		{
 			int filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
-			mc_filter[filterbit >> 5] |= cpu_to_le32(1 << (filterbit & 31));
+			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 		}
 		new_mode = CMR2h_Normal;
 	}
