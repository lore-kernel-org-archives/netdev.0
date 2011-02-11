From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 06/15] be2net: Cleanup the VF interface handles
Date: Fri, 11 Feb 2011 17:35:56 -0600
Message-ID: <20110211233556.GA18372@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51184 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757312Ab1BKXgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:36:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PF needs to cleanup all the interface handles that it created for the VFs.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 48eef9e..fc119d1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2340,6 +2340,8 @@ do_none:
 
 static int be_clear(struct be_adapter *adapter)
 {
+	int vf;
+
 	if (be_physfn(adapter) && adapter->sriov_enabled)
 		be_vf_eth_addr_rem(adapter);
 
@@ -2347,6 +2349,13 @@ static int be_clear(struct be_adapter *adapter)
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
 
+	if (be_physfn(adapter) && adapter->sriov_enabled)
+		for (vf = 0; vf < num_vfs; vf++)
+			if (adapter->vf_cfg[vf].vf_if_handle)
+				be_cmd_if_destroy(adapter,
+					adapter->vf_cfg[vf].vf_if_handle,
+					vf + 1);
+
 	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
 	/* tell fw we're done with firing cmds */
-- 
1.7.1

