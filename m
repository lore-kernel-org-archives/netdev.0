From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net] net:ethernet:aquantia: Fix for RX checksum offload.
Date: Wed, 22 Mar 2017 20:21:10 +0300
Message-ID: <cc4fcad0ba1a6e7ae7c55cd15fe0b4e23650c04e.1490203234.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0048.outbound.protection.outlook.com ([104.47.38.48]:36225
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933161AbdCVRVf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 13:21:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Since AQC-100/107/08 chips supports hardware checksums for RX we should indicate
this via NETIF_F_RXCSUM flag.
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0_internal.h | 1 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0_internal.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0_internal.h
index 1093ea1..0592a03 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0_internal.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0_internal.h
@@ -137,6 +137,7 @@ static struct aq_hw_caps_s hw_atl_a0_hw_caps_ = {
 	.tx_rings = HW_ATL_A0_TX_RINGS,
 	.rx_rings = HW_ATL_A0_RX_RINGS,
 	.hw_features = NETIF_F_HW_CSUM |
+			NETIF_F_RXCSUM |
 			NETIF_F_RXHASH |
 			NETIF_F_SG |
 			NETIF_F_TSO,
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
index 8bdee3d..f3957e93 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
@@ -188,6 +188,7 @@ static struct aq_hw_caps_s hw_atl_b0_hw_caps_ = {
 	.tx_rings = HW_ATL_B0_TX_RINGS,
 	.rx_rings = HW_ATL_B0_RX_RINGS,
 	.hw_features = NETIF_F_HW_CSUM |
+			NETIF_F_RXCSUM |
 			NETIF_F_RXHASH |
 			NETIF_F_SG |
 			NETIF_F_TSO |
-- 
2.7.4
