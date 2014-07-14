From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: Add 40G link capability decoding
Date: Mon, 14 Jul 2014 08:39:07 +0100
Message-ID: <53C3891B.5020506@solarflare.com>
References: <53C388A2.5040705@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:3029 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750731AbaGNHrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 03:47:14 -0400
In-Reply-To: <53C388A2.5040705@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

Needed to select 40G mode on a 10G/40G capable card.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_port.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index e5fc4e1..fb19b70 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -183,6 +183,8 @@ static u32 mcdi_to_ethtool_cap(u32 media, u32 cap)
 			result |= SUPPORTED_1000baseKX_Full;
 		if (cap & (1 << MC_CMD_PHY_CAP_10000FDX_LBN))
 			result |= SUPPORTED_10000baseKX4_Full;
+		if (cap & (1 << MC_CMD_PHY_CAP_40000FDX_LBN))
+			result |= SUPPORTED_40000baseKR4_Full;
 		break;
 
 	case MC_CMD_MEDIA_XFP:
@@ -190,6 +192,12 @@ static u32 mcdi_to_ethtool_cap(u32 media, u32 cap)
 		result |= SUPPORTED_FIBRE;
 		break;
 
+	case MC_CMD_MEDIA_QSFP_PLUS:
+		result |= SUPPORTED_FIBRE;
+		if (cap & (1 << MC_CMD_PHY_CAP_40000FDX_LBN))
+			result |= SUPPORTED_40000baseCR4_Full;
+		break;
+
 	case MC_CMD_MEDIA_BASE_T:
 		result |= SUPPORTED_TP;
 		if (cap & (1 << MC_CMD_PHY_CAP_10HDX_LBN))
@@ -237,6 +245,8 @@ static u32 ethtool_to_mcdi_cap(u32 cap)
 		result |= (1 << MC_CMD_PHY_CAP_1000FDX_LBN);
 	if (cap & (SUPPORTED_10000baseT_Full | SUPPORTED_10000baseKX4_Full))
 		result |= (1 << MC_CMD_PHY_CAP_10000FDX_LBN);
+	if (cap & (SUPPORTED_40000baseCR4_Full | SUPPORTED_40000baseKR4_Full))
+		result |= (1 << MC_CMD_PHY_CAP_40000FDX_LBN);
 	if (cap & SUPPORTED_Pause)
 		result |= (1 << MC_CMD_PHY_CAP_PAUSE_LBN);
 	if (cap & SUPPORTED_Asym_Pause)
@@ -285,6 +295,7 @@ static u32 mcdi_to_ethtool_media(u32 media)
 
 	case MC_CMD_MEDIA_XFP:
 	case MC_CMD_MEDIA_SFP_PLUS:
+	case MC_CMD_MEDIA_QSFP_PLUS:
 		return PORT_FIBRE;
 
 	case MC_CMD_MEDIA_BASE_T:
