From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 6/7] bnx2x: Fix no link on 577xx 10G-baseT
Date: Wed, 31 Oct 2012 17:46:57 +0200
Message-ID: <1351698418-10005-7-git-send-email-dmitry@broadcom.com>
References: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>,
	"Barak Witkowski" <barak@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: ariele@broadcom.com, eilong@broadcom.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3118 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757952Ab2JaPru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 11:47:50 -0400
In-Reply-To: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Since the Warpcore supports various link types, need to set only the correct
supported modes for XFI which is the serdes interface for the 10G-baseT PHY.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 679d45e..6dd0dd0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11528,6 +11528,11 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 			phy->media_type = ETH_PHY_BASE_T;
 			break;
 		case PORT_HW_CFG_NET_SERDES_IF_XFI:
+			phy->supported &= (SUPPORTED_1000baseT_Full |
+					   SUPPORTED_10000baseT_Full |
+					   SUPPORTED_FIBRE |
+					   SUPPORTED_Pause |
+					   SUPPORTED_Asym_Pause);
 			phy->media_type = ETH_PHY_XFP_FIBER;
 			break;
 		case PORT_HW_CFG_NET_SERDES_IF_SFI:
-- 
1.7.7.2
