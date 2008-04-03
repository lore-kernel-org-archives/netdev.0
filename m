From: Stefan Roese <sr@denx.de>
Subject: [PATCH] ibm_newemac: Add support for 460EX/GT-type MAL rx-channel handling
Date: Thu,  3 Apr 2008 13:45:10 +0200
Message-ID: <1207223110-27281-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:52410 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756373AbYDCLp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 07:45:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some 4xx PPC's (e.g. 460EX/GT), the rx channel number is a multiple
of 8 (e.g. 8 for EMAC1, 16 for EMAC2), but enabling in MAL_RXCASR needs
the divided by 8 value for the bitmask.

Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/mal.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 6869f08..fb9c9eb 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -136,6 +136,14 @@ void mal_enable_rx_channel(struct mal_instance *mal, int channel)
 {
 	unsigned long flags;
 
+	/*
+	 * On some 4xx PPC's (e.g. 460EX/GT), the rx channel is a multiple
+	 * of 8, but enabling in MAL_RXCASR needs the divided by 8 value
+	 * for the bitmask
+	 */
+	if (!(channel % 8))
+		channel >>= 3;
+
 	spin_lock_irqsave(&mal->lock, flags);
 
 	MAL_DBG(mal, "enable_rx(%d)" NL, channel);
@@ -148,6 +156,14 @@ void mal_enable_rx_channel(struct mal_instance *mal, int channel)
 
 void mal_disable_rx_channel(struct mal_instance *mal, int channel)
 {
+	/*
+	 * On some 4xx PPC's (e.g. 460EX/GT), the rx channel is a multiple
+	 * of 8, but enabling in MAL_RXCASR needs the divided by 8 value
+	 * for the bitmask
+	 */
+	if (!(channel % 8))
+		channel >>= 3;
+
 	set_mal_dcrn(mal, MAL_RXCARR, MAL_CHAN_MASK(channel));
 
 	MAL_DBG(mal, "disable_rx(%d)" NL, channel);
-- 
1.5.4.5

