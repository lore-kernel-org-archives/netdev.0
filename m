From: Roger Luethi <rl@hellgate.ch>
Subject: [3/3][PATCH 2.4] via-rhine: fix mc_filter on big-endian arch
Date: Sun, 6 Jun 2004 18:53:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040606165331.GA14002@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A.J. from VIA Networking Technologies noticed that via-rhine is using
cpu_to_le32() when preparing mc_filter hashes. This breaks Rhine hardware
multicast filters on big-endian architectures.

Please apply.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- 2.4-pre/drivers/net/via-rhine.c.orig	2004-06-06 18:12:07.825350069 +0200
+++ 2.4-pre/drivers/net/via-rhine.c	2004-06-06 18:08:45.834623930 +0200
@@ -1748,7 +1748,7 @@
 			 i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
-			mc_filter[bit_nr >> 5] |= cpu_to_le32(1 << (bit_nr & 31));
+			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 		}
 		writel(mc_filter[0], ioaddr + MulticastFilter0);
 		writel(mc_filter[1], ioaddr + MulticastFilter1);
