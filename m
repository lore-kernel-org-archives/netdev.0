From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH repost net-next] bnx2x: Add support for segmentation of tunnels with outer checksums
Date: Mon, 5 Sep 2016 13:26:33 +0300
Message-ID: <1473071193-24290-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexander.duyck@gmail.com>, Alexander Duyck <aduyck@mirantis.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:55787 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754247AbcIEK0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 06:26:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

I'm re-posting Alex's patch after some testing.
Please consider applying it to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index de2d326..6f9104b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13238,13 +13238,22 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO |
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
 	if (!chip_is_e1x) {
-		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
-				    NETIF_F_GSO_IPXIP4;
+		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_GRE_CSUM |
+				    NETIF_F_GSO_IPXIP4 |
+				    NETIF_F_GSO_UDP_TUNNEL |
+				    NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				    NETIF_F_GSO_PARTIAL;
+
 		dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 			NETIF_F_GSO_IPXIP4 |
-			NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
+			NETIF_F_GSO_GRE | NETIF_F_GSO_GRE_CSUM |
+			NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_UDP_TUNNEL_CSUM |
+			NETIF_F_GSO_PARTIAL;
+
+		dev->gso_partial_features = NETIF_F_GSO_GRE_CSUM |
+					    NETIF_F_GSO_UDP_TUNNEL_CSUM;
 	}
 
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-- 
1.9.3
