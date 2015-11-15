From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Fix VLANs null-pointer for 57710, 57711
Date: Sun, 15 Nov 2015 15:02:16 +0200
Message-ID: <1447592536-15744-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <osbart@redhat.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:27561 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbbKONCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 08:02:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 05cc5a39ddb7 "bnx2x: add vlan filtering offload" introduced
a regression in regard for vlans for 57710, 57711 adapters -
Loading 8021q module on a machine with such an adapter would cause
a null pointer dereference, as the driver mistakenly publishes it
has capabilities for vlan CTAG filtering.

Reported-by: Otto Sabart <osabart@redhat.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f1d62d5..c9b0367 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13207,7 +13207,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 
 	/* VF with OLD Hypervisor or old PF do not support filtering */
 	if (IS_PF(bp)) {
-		if (CHIP_IS_E1x(bp))
+		if (chip_is_e1x)
 			bp->accept_any_vlan = true;
 		else
 			dev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
-- 
1.9.3
