From: Joe Perches <joe@perches.com>
Subject: [PATCH 40/62] skge: Use static const
Date: Sat, 20 Nov 2010 18:38:41 -0800
Message-ID: <2ddff3ba3e1582bddc3b544dfcd22d8317df59cc.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  52665	    927	  12680	  66272	  102e0	drivers/net/skge.o.new
  52730	    927	  12680	  66337	  10321	drivers/net/skge.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 220e039..e9dbe52 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -1191,7 +1191,7 @@ static void genesis_init(struct skge_hw *hw)
 
 static void genesis_reset(struct skge_hw *hw, int port)
 {
-	const u8 zero[8]  = { 0 };
+	static const u8 zero[8]  = { 0 };
 	u32 reg;
 
 	skge_write8(hw, SK_REG(port, GMAC_IRQ_MSK), 0);
@@ -1557,7 +1557,7 @@ static void genesis_mac_init(struct skge_hw *hw, int port)
 	int jumbo = hw->dev[port]->mtu > ETH_DATA_LEN;
 	int i;
 	u32 r;
-	const u8 zero[6]  = { 0 };
+	static const u8 zero[6]  = { 0 };
 
 	for (i = 0; i < 10; i++) {
 		skge_write16(hw, SK_REG(port, TX_MFF_CTRL1),
-- 
1.7.3.2.245.g03276.dirty
