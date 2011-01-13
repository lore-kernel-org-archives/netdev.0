From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 04/10] GRETH: added greth_compat_mode module parameter
Date: Thu, 13 Jan 2011 09:25:29 +0100
Message-ID: <1294907135-24884-4-git-send-email-daniel@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755699Ab1AMJAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:05 -0500
In-Reply-To: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The greth_compat_mode option can be used to set a GRETH GBit capable MAC
in operate as if the GRETH 10/100 device was found. The GRETH GBit supports
TCP/UDP checksum offloading, unaligned frame buffers, scatter gather etc.
Enabling this mode allows the developer to test the GRETH 10/100 device
without all features mentioned above on a GBit MAC capable of the above.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index ef8da22..775dc24 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -70,6 +70,12 @@ static int no_gbit = 0;
 module_param(no_gbit, int, S_IRUGO);
 MODULE_PARM_DESC(no_gbit, "GRETH reports only 10/100 support to PHY layer if set to 1. Only affects GRETH GBit MAC, default 0 (off).");
 
+/* Use this option to enable GRETH 10/100 code on GRETH_GBIT hardware
+ * (debug legacy code option) */
+static int compat_mode = 0;
+module_param(compat_mode, int, S_IRUGO);
+MODULE_PARM_DESC(compat_mode, "GRETH 10/100 legacy mode enable. Only affects GRETH GBit MAC, default 0 (off).");
+
 static int greth_open(struct net_device *dev);
 static netdev_tx_t greth_start_xmit(struct sk_buff *skb,
 	   struct net_device *dev);
@@ -1458,6 +1464,10 @@ static int __devinit greth_of_probe(struct platform_device *ofdev, const struct
 	else
 		greth->gbit_phy_support = 0;
 
+	/* Force GBit MAC in legacy 10/100 mode (no offloading etc.) */
+	if (compat_mode == 1)
+		greth->gbit_mac = 0;
+
 	/* Check for multicast capability */
 	greth->multicast = (tmp >> 25) & 1;
 
-- 
1.5.4

