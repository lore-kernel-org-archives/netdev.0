From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next 4/7] net/faraday: Avoid PHYSTS_CHG interrupt
Date: Tue, 20 Sep 2016 16:00:04 +0930
Message-ID: <20160920063007.24291-5-joel@jms.id.au>
References: <20160920063007.24291-1-joel@jms.id.au>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, andrew@lunn.ch,
        andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920063007.24291-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gavin Shan <gwshan@linux.vnet.ibm.com>

Bit#11 in MACCR (0x50) designates the signal level for PHY link
status change. It's cleared, meaning high level enabled, by default.
However, we can see continuous interrupt (bit#6) in ISR (0x0) for it
and it's obviously a false alarm. The side effect is CPU cycles wasted
to process the false alarm.

This sets bit#11 in MACCR (0x50) to avoid the bogus interrupt.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 1 +
 drivers/net/ethernet/faraday/ftgmac100.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 47f512224b57..f2ea6c2f1fbd 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -215,6 +215,7 @@ static void ftgmac100_init_hw(struct ftgmac100 *priv)
 				 FTGMAC100_MACCR_RXMAC_EN	| \
 				 FTGMAC100_MACCR_FULLDUP	| \
 				 FTGMAC100_MACCR_CRC_APD	| \
+				 FTGMAC100_MACCR_PHY_LINK_LEVEL | \
 				 FTGMAC100_MACCR_RX_RUNT	| \
 				 FTGMAC100_MACCR_RX_BROADPKT)
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index c258586ce4a4..d07b6ea5d1b5 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -152,6 +152,7 @@
 #define FTGMAC100_MACCR_FULLDUP		(1 << 8)
 #define FTGMAC100_MACCR_GIGA_MODE	(1 << 9)
 #define FTGMAC100_MACCR_CRC_APD		(1 << 10)
+#define FTGMAC100_MACCR_PHY_LINK_LEVEL	(1 << 11)
 #define FTGMAC100_MACCR_RX_RUNT		(1 << 12)
 #define FTGMAC100_MACCR_JUMBO_LF	(1 << 13)
 #define FTGMAC100_MACCR_RX_ALL		(1 << 14)
-- 
2.9.3
