From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 2/3] veth: Update features to include all tunnel
 GSO types
Date: Wed, 20 Apr 2016 10:49:12 -0400
Message-ID: <20160420144912.3100.70799.stgit@ahduyck-xeon-server>
References: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33888 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbcDTOtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 10:49:22 -0400
Received: by mail-pa0-f44.google.com with SMTP id r5so16843100pag.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 07:49:22 -0700 (PDT)
In-Reply-To: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the checksum enabled versions of UDP and GRE
tunnels.  With this change we should be able to send and receive GSO frames
of these types over the veth pair without needing to segment the packets.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/veth.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 4f30a6ae50d0..f37a6e61d4ad 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -312,10 +312,9 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_set_rx_headroom	= veth_set_rx_headroom,
 };
 
-#define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
-		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
-		       NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |	    \
-		       NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT | NETIF_F_UFO	|   \
+#define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HW_CSUM | \
+		       NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
+		       NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ENCAP_ALL | \
 		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
 		       NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )
 
