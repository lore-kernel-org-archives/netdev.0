From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] i40evf: always activate correct MAC address filter
Date: Tue, 28 Jun 2016 21:40:57 -0700
Message-ID: <1467175262-54719-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62810 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbcF2EnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:19 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Always add MAC address at the tail of the MAC filter list. Since the
device's "real" MAC address is added first, it will always be at the
beginning of the list. This prevents an issue where the "real" MAC
filter might not get added if too many other filters are added before
bringing the interface up.

Change-ID: I34a8aeebeb0cb87a44b24118adc4176c7b943c1c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 16c5529..da9221b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -825,7 +825,7 @@ i40evf_mac_filter *i40evf_add_filter(struct i40evf_adapter *adapter,
 
 		ether_addr_copy(f->macaddr, macaddr);
 
-		list_add(&f->list, &adapter->mac_filter_list);
+		list_add_tail(&f->list, &adapter->mac_filter_list);
 		f->add = true;
 		adapter->aq_required |= I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	}
-- 
2.5.5
