From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 2/6] ibm_newemac: Add support for 460EX/GT-type MAL rx-channel handling
Date: Tue, 22 Apr 2008 10:46:42 +1000
Message-ID: <20080422004758.DB022DE1C0@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43405 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755650AbYDVAsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 20:48:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>

On some 4xx PPC's (e.g. 460EX/GT), the rx channel number is a multiple
of 8 (e.g. 8 for EMAC1, 16 for EMAC2), but enabling in MAL_RXCASR needs
the divided by 8 value for the bitmask.

Signed-off-by: Stefan Roese <sr@denx.de>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

---
 drivers/net/ibm_newemac/mal.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

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

