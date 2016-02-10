From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] be2net: don't report EVB for older chipsets when SR-IOV is disabled
Date: Wed, 10 Feb 2016 13:13:20 +0100
Message-ID: <1455106400-16330-1-git-send-email-ivecera@redhat.com>
Cc: Sathya Perla <sathya.perla@broadcom.com>,
	Ajit Khaparde <ajit.khaparde@broadcom.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbcBJMNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 07:13:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EVB (virtual bridge) functionality should be disabled on older BE3
and Lancer chips if SR-IOV is disabled in the NIC's BIOS. This setting
is identified by the zero value of total VFs reported by the card.
The GET_HSW_CONFIG command cannot be used as it is not supported by
these older chipset's FW.

Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9c1fc9d..886fe95 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4588,6 +4588,8 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 
 	/* BE and Lancer chips support VEB mode only */
 	if (BEx_chip(adapter) || lancer_chip(adapter)) {
+		if (!pci_sriov_get_totalvfs(adapter->pdev))
+			return 0;
 		hsw_mode = PORT_FWD_TYPE_VEB;
 	} else {
 		status = be_cmd_get_hsw_config(adapter, NULL, 0,
-- 
2.4.10
