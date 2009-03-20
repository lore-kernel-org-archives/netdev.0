From: Sathya Perla <sathya.perla@gmail.com>
Subject: Re: [PATCH 2/2] be2net: fix to restore vlan ids into BE2 during a IF
	DOWN->UP cycle
Date: Fri, 20 Mar 2009 15:52:39 +0530
Message-ID: <bdc3ac9f0903200322n3993a7fdx9ac25a3d0b14edec@mail.gmail.com>
References: <1237454167.6210.24.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:35937 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758410AbZCTKWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:22:41 -0400
Received: by wa-out-1112.google.com with SMTP id j5so612461wah.21
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2009 03:22:39 -0700 (PDT)
In-Reply-To: <1237454167.6210.24.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 2:46 PM, Sathya Perla <sathyap@serverengines.com> wrote:
> Hi, this is a patch to reconfigure vlan-ids during an i/f down/up cycle
>
> thanks,
> -Sathya

Re-posting the patch:

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 80fe1e0..0ecaffb 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -473,7 +473,7 @@ static int be_change_mtu(struct net_device
*netdev, int new_mtu)
  * program them in BE.  If more than BE_NUM_VLANS_SUPPORTED are configured,
  * set the BE in promiscuous VLAN mode.
  */
-static void be_vids_config(struct net_device *netdev)
+static void be_vid_config(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	u16 vtag[BE_NUM_VLANS_SUPPORTED];
@@ -516,7 +516,7 @@ static void be_vlan_add_vid(struct net_device
*netdev, u16 vid)
 	adapter->num_vlans++;
 	adapter->vlan_tag[vid] = 1;

-	be_vids_config(netdev);
+	be_vid_config(netdev);
 }

 static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
@@ -527,7 +527,7 @@ static void be_vlan_rem_vid(struct net_device
*netdev, u16 vid)
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
