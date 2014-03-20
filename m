From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] igb: Convert uses of __constant_<foo> to <foo>
Date: Thu, 20 Mar 2014 01:32:53 -0700
Message-ID: <1395304385-6874-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8065 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755499AbaCTIds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:48 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 313e1a8..17feea0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4592,7 +4592,7 @@ static int igb_tso(struct igb_ring *tx_ring,
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
 
-	if (first->protocol == __constant_htons(ETH_P_IP)) {
+	if (first->protocol == htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
@@ -4648,12 +4648,12 @@ static void igb_tx_csum(struct igb_ring *tx_ring, struct igb_tx_buffer *first)
 	} else {
 		u8 l4_hdr = 0;
 		switch (first->protocol) {
-		case __constant_htons(ETH_P_IP):
+		case htons(ETH_P_IP):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
 			l4_hdr = ip_hdr(skb)->protocol;
 			break;
-		case __constant_htons(ETH_P_IPV6):
+		case htons(ETH_P_IPV6):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			l4_hdr = ipv6_hdr(skb)->nexthdr;
 			break;
@@ -6738,7 +6738,7 @@ static unsigned int igb_get_headlen(unsigned char *data,
 	hdr.network += ETH_HLEN;
 
 	/* handle any vlan tag if present */
-	if (protocol == __constant_htons(ETH_P_8021Q)) {
+	if (protocol == htons(ETH_P_8021Q)) {
 		if ((hdr.network - data) > (max_len - VLAN_HLEN))
 			return max_len;
 
@@ -6747,7 +6747,7 @@ static unsigned int igb_get_headlen(unsigned char *data,
 	}
 
 	/* handle L3 protocols */
-	if (protocol == __constant_htons(ETH_P_IP)) {
+	if (protocol == htons(ETH_P_IP)) {
 		if ((hdr.network - data) > (max_len - sizeof(struct iphdr)))
 			return max_len;
 
@@ -6761,7 +6761,7 @@ static unsigned int igb_get_headlen(unsigned char *data,
 		/* record next protocol if header is present */
 		if (!(hdr.ipv4->frag_off & htons(IP_OFFSET)))
 			nexthdr = hdr.ipv4->protocol;
-	} else if (protocol == __constant_htons(ETH_P_IPV6)) {
+	} else if (protocol == htons(ETH_P_IPV6)) {
 		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
 			return max_len;
 
-- 
1.8.3.1
