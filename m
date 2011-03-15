From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Fix UDP packet detected status in RX compl
Date: Tue, 15 Mar 2011 15:59:01 +0530
Message-ID: <fa0d690e-8b0a-4608-be17-d65c22246f37@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:13877 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755702Ab1COK36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:29:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Status of UDP packet detection not getting populated in RX completion
structure. This is required in csum_passed() routine.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 3cb5f4e..5e15006 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1088,6 +1088,7 @@ static void be_parse_rx_compl_v1(struct be_adapter *adapter,
 	rxcp->vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtp, compl);
 	rxcp->err = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, err, compl);
 	rxcp->tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, tcpf, compl);
+	rxcp->udpf = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, udpf, compl);
 	rxcp->ip_csum =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, ipcksm, compl);
 	rxcp->l4_csum =
@@ -1113,6 +1114,7 @@ static void be_parse_rx_compl_v0(struct be_adapter *adapter,
 	rxcp->vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtp, compl);
 	rxcp->err = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, err, compl);
 	rxcp->tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, tcpf, compl);
+	rxcp->udpf = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, udpf, compl);
 	rxcp->ip_csum =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, ipcksm, compl);
 	rxcp->l4_csum =
-- 
1.6.0.2

