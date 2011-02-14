From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 5/9] jme: Fix hardware action of full-duplex
Date: Mon, 14 Feb 2011 12:27:38 +0800
Message-ID: <1297657662-30289-5-git-send-email-cooldavid@cooldavid.org>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48728 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755474Ab1BNE22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:28 -0500
In-Reply-To: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Clear Transmit Timer/Retry setting while full-duplex.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    6 ++----
 drivers/net/jme.h |    8 ++++++++
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 490bc0f..6996d04 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -439,16 +439,14 @@ jme_check_link(struct net_device *netdev, int testonly)
 
 		if (phylink & PHY_LINK_DUPLEX) {
 			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT);
+			jwrite32(jme, JME_TXTRHD, TXTRHD_FULLDUPLEX);
 			ghc |= GHC_DPX;
 		} else {
 			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT |
 						TXMCS_BACKOFF |
 						TXMCS_CARRIERSENSE |
 						TXMCS_COLLISION);
-			jwrite32(jme, JME_TXTRHD, TXTRHD_TXPEN |
-				((0x2000 << TXTRHD_TXP_SHIFT) & TXTRHD_TXP) |
-				TXTRHD_TXREN |
-				((8 << TXTRHD_TXRL_SHIFT) & TXTRHD_TXRL));
+			jwrite32(jme, JME_TXTRHD, TXTRHD_HALFDUPLEX);
 		}
 
 		gpreg1 = GPREG1_DEFAULT;
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index dc4af57..b33bc5b 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -658,6 +658,14 @@ enum jme_txtrhd_shifts {
 	TXTRHD_TXRL_SHIFT	= 0,
 };
 
+enum jme_txtrhd_values {
+	TXTRHD_FULLDUPLEX	= 0x00000000,
+	TXTRHD_HALFDUPLEX	= TXTRHD_TXPEN |
+				  ((0x2000 << TXTRHD_TXP_SHIFT) & TXTRHD_TXP) |
+				  TXTRHD_TXREN |
+				  ((8 << TXTRHD_TXRL_SHIFT) & TXTRHD_TXRL),
+};
+
 /*
  * RX Control/Status Bits
  */
-- 
1.7.2.2

