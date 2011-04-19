From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 5/5] be2net: add code to display default value of
 tx rate for VFs
Date: Tue, 19 Apr 2011 17:11:55 -0500
Message-ID: <20110419221155.GA3676@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:3025 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756068Ab1DSWNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 18:13:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change will allow the default value of tx rate to be displayed
when ip link show is called on a PF interface.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 77a6e7e..3529400 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3082,9 +3082,22 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 
 	if (be_physfn(adapter) && adapter->sriov_enabled) {
+		u8 mac_speed;
+		bool link_up;
+		u16 vf, lnk_speed;
+
 		status = be_vf_eth_addr_config(adapter);
 		if (status)
 			goto unreg_netdev;
+
+		for (vf = 0; vf < num_vfs; vf++) {
+			status = be_cmd_link_status_query(adapter, &link_up,
+					&mac_speed, &lnk_speed, vf + 1);
+			if (!status)
+				adapter->vf_cfg[vf].vf_tx_rate = lnk_speed * 10;
+			else
+				goto unreg_netdev;
+		}
 	}
 
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
-- 
1.7.1

