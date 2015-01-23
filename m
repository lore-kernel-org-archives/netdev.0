From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] fm10k: Check tunnel header length in encap offload
Date: Thu, 22 Jan 2015 18:37:07 -0800
Message-ID: <1421980631-1955-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16348 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718AbbAWChV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:21 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>

fm10k supports up to 184 bytes of inner+outer headers. Add an initial
check to fail encap offload if these are too large.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index c7a19a5..84ab9ee 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -727,6 +727,12 @@ static __be16 fm10k_tx_encap_offload(struct sk_buff *skb)
 	struct ethhdr *eth_hdr;
 	u8 l4_hdr = 0;
 
+/* fm10k supports 184 octets of outer+inner headers. Minus 20 for inner L4. */
+#define FM10K_MAX_ENCAP_TRANSPORT_OFFSET	164
+	if (skb_inner_transport_header(skb) - skb_mac_header(skb) >
+	    FM10K_MAX_ENCAP_TRANSPORT_OFFSET)
+		return 0;
+
 	switch (vlan_get_protocol(skb)) {
 	case htons(ETH_P_IP):
 		l4_hdr = ip_hdr(skb)->protocol;
-- 
1.9.3
