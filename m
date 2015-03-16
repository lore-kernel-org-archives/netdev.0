From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] bnx2x: fix encapsulation features on 57710/57711
Date: Mon, 16 Mar 2015 16:15:59 +0100
Message-ID: <1426518959-17883-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	=?UTF-8?q?Eren=20T=C3=BCrkay?= <erent@skyatlas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932199AbbCPPQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 11:16:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

E1x chips (57710, 57711(E)) have no support for encapsulation
offload. bnx2x incorrectly advertises the support as available.

Setting of those features is conditional on "!CHIP_IS_E1x(bp)", but
the bp struct is not initialized yet at this point and consequently
any chip passes the check.
The check must use the "chip_is_e1x" local variable instead to work
correctly.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index bef750a090..996e215fc3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12769,7 +12769,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO |
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
-	if (!CHIP_IS_E1x(bp)) {
+	if (!chip_is_e1x) {
 		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
 				    NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
 		dev->hw_enc_features =
-- 
2.1.0
