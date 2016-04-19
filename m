From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 4/5] bnxt: Add support for segmentation of tunnels with
 outer checksums
Date: Tue, 19 Apr 2016 15:06:15 -0400
Message-ID: <20160419190615.11723.53966.stgit@ahduyck-xeon-server>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eugenia@mellanox.com, bruce.w.allan@intel.com, saeedm@mellanox.com,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	ariel.elior@qlogic.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32985 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933452AbcDSTGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 15:06:30 -0400
Received: by mail-pa0-f52.google.com with SMTP id zm5so9360720pac.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 12:06:30 -0700 (PDT)
In-Reply-To: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch assumes that the bnxt hardware will ignore existing IPv4/v6
header fields for length and checksum as well as the length and checksum
fields for outer UDP and GRE headers.

I have no means of testing this as I do not have any bnx2x hardware but
thought I would submit it as an RFC to see if anyone out there wants to
test this and see if this does in fact enable this functionality allowing
us to to segment tunneled frames that have an outer checksum.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4645c44e7c15..ae668476fff0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6194,14 +6194,19 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_TSO | NETIF_F_TSO6 |
 			   NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
 			   NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
-			   NETIF_F_RXHASH |
+			   NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
+			   NETIF_F_GSO_PARTIAL | NETIF_F_RXHASH |
 			   NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO;
 
 	dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO6 |
 			NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
-			NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
+			NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
+			NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
+			NETIF_F_GSO_PARTIAL;
+	dev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				    NETIF_F_GSO_GRE_CSUM;
 	dev->vlan_features = dev->hw_features | NETIF_F_HIGHDMA;
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_TX |
 			    NETIF_F_HW_VLAN_STAG_RX | NETIF_F_HW_VLAN_STAG_TX;
