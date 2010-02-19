From: Carsten Behling <carsten.behling@garz-fricke.com>
Subject: [PATCH 1/1] add net fec phy lan8700
Date: Fri, 19 Feb 2010 15:21:35 +0100
Message-ID: <D99582E5322435468A77E74BB0039E7B176E1F3BC4@SRV02.hamburg.garz-fricke.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kernel@pengutronix.de" <kernel@pengutronix.de>,
	"dmalek@jlc.net" <dmalek@jlc.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.artfiles.de ([80.252.97.80]:43801 "EHLO
	mailout.artfiles.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193Ab0BSOqe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 09:46:34 -0500
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Carsten Behling <carsten.behling@garz-fricke.com>
---
 Add support for lan8700 PHY.
 drivers/net/fec.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 16a1d58..f739aca 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1128,6 +1128,29 @@ static phy_info_t phy_info_dp83848= {
        },
 };

+static phy_info_t phy_info_lan8700 = {
+       0x00007C0C,
+       "LAN8700",
+
+       (const phy_cmd_t []) {  /* config */
+               { mk_mii_read(MII_REG_CR), mii_parse_cr },
+               { mk_mii_read(MII_REG_ANAR), mii_parse_anar },
+               { mk_mii_end, }
+       },
+       (const phy_cmd_t []) {  /* startup - enable interrupts */
+               { mk_mii_write(MII_REG_CR, 0x1200), NULL }, /* autonegotiate */
+
+               { mk_mii_read(MII_REG_SR), mii_parse_sr },
+               { mk_mii_end, }
+       },
+       (const phy_cmd_t []) { /* ack_int - never happens, no interrupt */
+               { mk_mii_end, }
+       },
+       (const phy_cmd_t []) {  /* shutdown */
+               { mk_mii_end, }
+       },
+};
+
 /* ------------------------------------------------------------------------- */

 static phy_info_t const * const phy_info[] = {
@@ -1137,6 +1160,7 @@ static phy_info_t const * const phy_info[] = {
        &phy_info_am79c874,
        &phy_info_ks8721bl,
        &phy_info_dp83848,
+       &phy_info_lan8700,
        NULL
 };

--
1.6.0.2

