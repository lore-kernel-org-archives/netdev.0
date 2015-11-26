From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v2 net 3/6] net: mvneta: fix bit assignment for RX packet irq enable
Date: Thu, 26 Nov 2015 19:08:10 +0100
Message-ID: <1448561293-16431-4-git-send-email-mw@semihalf.com>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com, <stable@vger.kernel.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34181 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbbKZSI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 13:08:27 -0500
Received: by lffu14 with SMTP id u14so105855859lff.1
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 10:08:25 -0800 (PST)
In-Reply-To: <1448561293-16431-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A value originally defined in the driver was inappropriate. Even though
the ingress was somehow working, writing MVNETA_RXQ_INTR_ENABLE_ALL_MASK
to MVNETA_INTR_ENABLE didn't make any effect, because the bits [31:16]
are reserved and read-only.

This commit updates MVNETA_RXQ_INTR_ENABLE_ALL_MASK to be compliant with
the controller's documentation.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Cc: <stable@vger.kernel.org> # v3.8+
Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network
unit")
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index d78edbb..0c3d923 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -160,7 +160,7 @@
 
 #define MVNETA_INTR_ENABLE                       0x25b8
 #define      MVNETA_TXQ_INTR_ENABLE_ALL_MASK     0x0000ff00
-#define      MVNETA_RXQ_INTR_ENABLE_ALL_MASK     0xff000000  // note: neta says it's 0x000000FF
+#define      MVNETA_RXQ_INTR_ENABLE_ALL_MASK     0x000000ff
 
 #define MVNETA_RXQ_CMD                           0x2680
 #define      MVNETA_RXQ_DISABLE_SHIFT            8
-- 
1.8.3.1
