From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] igb: Don't give VFs random MAC addresses
Date: Mon, 28 Jan 2013 01:04:28 -0800
Message-ID: <1359363869-32391-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23510 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702Ab3A1JEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:42 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

If the user has not assigned a MAC address to a VM, then don't give it a
random one. Instead, just give it zeros and let it figure out what to do
with them.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b81a953..a59e630 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5197,7 +5197,7 @@ static int igb_vf_configure(struct igb_adapter *adapter, int vf)
 {
 	unsigned char mac_addr[ETH_ALEN];
 
-	eth_random_addr(mac_addr);
+	eth_zero_addr(mac_addr);
 	igb_set_vf_mac(adapter, vf, mac_addr);
 
 	return 0;
@@ -5550,9 +5550,9 @@ static void igb_vf_reset_event(struct igb_adapter *adapter, u32 vf)
 {
 	unsigned char *vf_mac = adapter->vf_data[vf].vf_mac_addresses;
 
-	/* generate a new mac address as we were hotplug removed/added */
+	/* clear mac address as we were hotplug removed/added */
 	if (!(adapter->vf_data[vf].flags & IGB_VF_FLAG_PF_SET_MAC))
-		eth_random_addr(vf_mac);
+		eth_zero_addr(vf_mac);
 
 	/* process remaining reset events */
 	igb_vf_reset(adapter, vf);
-- 
1.7.11.7
