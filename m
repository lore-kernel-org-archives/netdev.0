From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH 11/13] can: at91_can: use endian agnostic IO accessors
Date: Wed, 18 Mar 2015 15:53:10 +0000
Message-ID: <1426693992-31163-12-git-send-email-ben.dooks@codethink.co.uk>
References: <1426693992-31163-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: linux-kernel@lists.codethink.co.uk,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:32884 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998AbbCRPxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 11:53:51 -0400
In-Reply-To: <1426693992-31163-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change __raw accesors to  endian agnostic versions to allow the driver
to work properly on big endian systems.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
--
CC: Wolfgang Grandegger <wg@grandegger.com>
CC: Marc Kleine-Budde <mkl@pengutronix.de>
CC: linux-can@vger.kernel.org
CC: netdev@vger.kernel.org
CC: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/can/at91_can.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index eeb4b8b..f4e40aa 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -291,13 +291,13 @@ static inline unsigned int get_tx_echo_mb(const struct at91_priv *priv)
 
 static inline u32 at91_read(const struct at91_priv *priv, enum at91_reg reg)
 {
-	return __raw_readl(priv->reg_base + reg);
+	return readl_relaxed(priv->reg_base + reg);
 }
 
 static inline void at91_write(const struct at91_priv *priv, enum at91_reg reg,
 		u32 value)
 {
-	__raw_writel(value, priv->reg_base + reg);
+	writel_relaxed(value, priv->reg_base + reg);
 }
 
 static inline void set_mb_mode_prio(const struct at91_priv *priv,
-- 
2.1.4
