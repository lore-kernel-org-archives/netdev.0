From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] e1000e: Cleanup return values in ethtool
Date: Wed, 23 Apr 2014 04:15:19 -0700
Message-ID: <1398251726-13638-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6546 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753131AbaDWLPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:36 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Changing occurrences of returning 0 and 1 from bool functions to false and
true, respectively

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 8 ++++----
 drivers/net/ethernet/intel/e1000e/netdev.c  | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index cad250b..2204a9c 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -783,10 +783,10 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 			      reg + (offset << 2), val,
 			      (test[pat] & write & mask));
 			*data = reg;
-			return 1;
+			return true;
 		}
 	}
-	return 0;
+	return false;
 }
 
 static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
@@ -799,9 +799,9 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 		e_err("set/check test failed (reg 0x%05X): got 0x%08X expected 0x%08X\n",
 		      reg, (val & mask), (write & mask));
 		*data = reg;
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 #define REG_PATTERN_TEST_ARRAY(reg, offset, mask, write)                       \
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index d50c91e..255481c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5170,7 +5170,7 @@ static bool e1000_tx_csum(struct e1000_ring *tx_ring, struct sk_buff *skb)
 	__be16 protocol;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		return 0;
+		return false;
 
 	if (skb->protocol == cpu_to_be16(ETH_P_8021Q))
 		protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
@@ -5215,7 +5215,7 @@ static bool e1000_tx_csum(struct e1000_ring *tx_ring, struct sk_buff *skb)
 		i = 0;
 	tx_ring->next_to_use = i;
 
-	return 1;
+	return true;
 }
 
 static int e1000_tx_map(struct e1000_ring *tx_ring, struct sk_buff *skb,
-- 
1.9.0
