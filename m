From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 2/7] be2net: Checksum field valid only for TCP/UDP
Date: Mon, 7 Mar 2011 18:38:16 +0530
Message-ID: <79e10ac8-3f25-4ee2-9a0d-08d39cd9fe9c@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52331 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753948Ab1CGNIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:08:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L4 checksum field is valid only for TCP/UDP packets in Lancer

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
---
 drivers/net/benet/be_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index bf34434..ac7ae21 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -865,14 +865,17 @@ static void be_rx_stats_update(struct be_rx_obj *rxo,
 
 static inline bool csum_passed(struct be_eth_rx_compl *rxcp)
 {
-	u8 l4_cksm, ipv6, ipcksm;
+	u8 l4_cksm, ipv6, ipcksm, tcpf, udpf;
 
 	l4_cksm = AMAP_GET_BITS(struct amap_eth_rx_compl, l4_cksm, rxcp);
 	ipcksm = AMAP_GET_BITS(struct amap_eth_rx_compl, ipcksm, rxcp);
 	ipv6 = AMAP_GET_BITS(struct amap_eth_rx_compl, ip_version, rxcp);
+	tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
+	udpf = AMAP_GET_BITS(struct amap_eth_rx_compl, udpf, rxcp);
 
-	/* Ignore ipcksm for ipv6 pkts */
-	return l4_cksm && (ipcksm || ipv6);
+	/* L4 checksum is not reliable for non TCP/UDP packets.
+	 * Also ignore ipcksm for ipv6 pkts */
+	return (tcpf || udpf) && l4_cksm && (ipcksm || ipv6);
 }
 
 static struct be_rx_page_info *
-- 
1.6.0.2

