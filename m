From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/18] i40e/i40evf: Add missing packet types for VXLAN encapsulated packet types
Date: Sat, 28 Feb 2015 03:29:43 -0800
Message-ID: <1425122989-354-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377AbbB1LaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:30:00 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We were missing a few packet types for VXLAN offload. This patch fixes
that.

Change-ID: I4b23aa0b08e40ed49d0df6c49a5ed9f2009b44ce
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 8 ++++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 352dafe..af35062 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1354,10 +1354,10 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	struct iphdr *iph;
 	__sum16 csum;
 
-	ipv4_tunnel = (rx_ptype > I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
-		      (rx_ptype < I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
-	ipv6_tunnel = (rx_ptype > I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
-		      (rx_ptype < I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
+	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index fc7e2d0..d2ff862 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -852,10 +852,10 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	struct iphdr *iph;
 	__sum16 csum;
 
-	ipv4_tunnel = (rx_ptype > I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
-		      (rx_ptype < I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
-	ipv6_tunnel = (rx_ptype > I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
-		      (rx_ptype < I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
+	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-- 
1.9.3
