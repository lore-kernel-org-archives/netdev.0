From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 5/5] net:ethernet:aquantia: Reset is_gso flag when EOP reached.
Date: Wed, 22 Mar 2017 20:06:31 +0300
Message-ID: <38ef69787d7ec45b541975ee66193bf27beca138.1490202165.git.pavel.belous@aquantia.com>
References: <cover.1490202165.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0070.outbound.protection.outlook.com ([104.47.40.70]:62429
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759680AbdCVRHk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 13:07:40 -0400
In-Reply-To: <cover.1490202165.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

We need to reset is_gso flag when EOP reached (entire LSO packet processed).

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c | 1 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
index d62436e..9db2efa 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
@@ -461,6 +461,7 @@ static int hw_atl_a0_hw_ring_tx_xmit(struct aq_hw_s *self,
 			if (unlikely(buff->is_eop)) {
 				txd->ctl |= HW_ATL_A0_TXD_CTL_EOP;
 				txd->ctl |= HW_ATL_A0_TXD_CTL_CMD_WB;
+				is_gso = false;
 			}
 		}
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index 69488c9..4215070 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -499,6 +499,7 @@ static int hw_atl_b0_hw_ring_tx_xmit(struct aq_hw_s *self,
 			if (unlikely(buff->is_eop)) {
 				txd->ctl |= HW_ATL_B0_TXD_CTL_EOP;
 				txd->ctl |= HW_ATL_B0_TXD_CTL_CMD_WB;
+				is_gso = false;
 			}
 		}
 
-- 
2.7.4
