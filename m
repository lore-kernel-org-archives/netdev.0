From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 08/15] i40evf: fix scan warning on sprintf
Date: Wed, 30 Jul 2014 17:32:04 -0700
Message-ID: <1406766731-4209-9-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24422 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040AbaGaA2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:19 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was converted to use snprintf everywhere but this one function.
Just use snprintf, instead of sprintf.

Also a small spelling correction in a comment.

Change-ID: I59d45f94a52754c7b4cd6034df9a61d8132b7f77
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index e70e4cd..efee6b2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -193,7 +193,7 @@ static void i40evf_set_msglevel(struct net_device *netdev, u32 data)
 }
 
 /**
- * i40evf_get_drvinto - Get driver info
+ * i40evf_get_drvinfo - Get driver info
  * @netdev: network interface device structure
  * @drvinfo: ethool driver info structure
  *
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index a53e81b..937785d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -527,7 +527,8 @@ static int i40evf_request_misc_irq(struct i40evf_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int err;
 
-	sprintf(adapter->misc_vector_name, "i40evf:mbx");
+	snprintf(adapter->misc_vector_name,
+		 sizeof(adapter->misc_vector_name) - 1, "i40evf:mbx");
 	err = request_irq(adapter->msix_entries[0].vector,
 			  &i40evf_msix_aq, 0,
 			  adapter->misc_vector_name, netdev);
-- 
1.9.3
