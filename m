From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH 2/2] be2net: fix to restore vlan ids into BE2 during a IF
 DOWN->UP cycle
Date: Thu, 19 Mar 2009 14:46:07 +0530
Message-ID: <1237454167.6210.24.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:17802 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbZCSJQO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 05:16:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, this is a patch to reconfigure vlan-ids during an i/f down/up cycle

thanks,
-Sathya
P.S: Pls ignore the "company confidential" warning at the end of the
patch emails.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 80fe1e0..0ecaffb 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -473,7 +473,7 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
  * program them in BE.  If more than BE_NUM_VLANS_SUPPORTED are configured,
  * set the BE in promiscuous VLAN mode.
  */
-static void be_vids_config(struct net_device *netdev)
+static void be_vid_config(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	u16 vtag[BE_NUM_VLANS_SUPPORTED];
@@ -516,7 +516,7 @@ static void be_vlan_add_vid(struct net_device *netdev, u16 vid)
 	adapter->num_vlans++;
 	adapter->vlan_tag[vid] = 1;
 
-	be_vids_config(netdev);
+	be_vid_config(netdev);
 }
 
 static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
@@ -527,7 +527,7 @@ static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 	adapter->vlan_tag[vid] = 0;
 
 	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
-	be_vids_config(netdev);
+	be_vid_config(netdev);
 }
 
 static void be_set_multicast_filter(struct net_device *netdev)
@@ -1430,6 +1430,8 @@ static int be_open(struct net_device *netdev)
 	if (status != 0)
 		goto do_none;
 
+	be_vid_config(netdev);
+
 	status = be_cmd_set_flow_control(ctrl, true, true);
 	if (status != 0)
 		goto if_destroy;
@@ -1864,8 +1866,6 @@ static int be_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
 
-	be_vids_config(netdev);
-
 	if (netif_running(netdev)) {
 		rtnl_lock();
 		be_open(netdev);
-- 
1.5.6.3





___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

