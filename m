From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] e1000e: cleanup - remove unnecessary variable
Date: Thu, 23 Aug 2012 02:56:45 -0700
Message-ID: <1345715813-20757-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59883 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758304Ab2HWJ46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:56:58 -0400
In-Reply-To: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index bc611b4..fb42152 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4660,7 +4660,7 @@ static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb)
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
 	u32 cmd_length = 0;
-	u16 ipcse = 0, tucse, mss;
+	u16 ipcse = 0, mss;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 
 	if (!skb_is_gso(skb))
@@ -4694,7 +4694,6 @@ static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb)
 	ipcso = (void *)&(ip_hdr(skb)->check) - (void *)skb->data;
 	tucss = skb_transport_offset(skb);
 	tucso = (void *)&(tcp_hdr(skb)->check) - (void *)skb->data;
-	tucse = 0;
 
 	cmd_length |= (E1000_TXD_CMD_DEXT | E1000_TXD_CMD_TSE |
 	               E1000_TXD_CMD_TCP | (skb->len - (hdr_len)));
@@ -4708,7 +4707,7 @@ static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb)
 	context_desc->lower_setup.ip_fields.ipcse  = cpu_to_le16(ipcse);
 	context_desc->upper_setup.tcp_fields.tucss = tucss;
 	context_desc->upper_setup.tcp_fields.tucso = tucso;
-	context_desc->upper_setup.tcp_fields.tucse = cpu_to_le16(tucse);
+	context_desc->upper_setup.tcp_fields.tucse = 0;
 	context_desc->tcp_seg_setup.fields.mss     = cpu_to_le16(mss);
 	context_desc->tcp_seg_setup.fields.hdr_len = hdr_len;
 	context_desc->cmd_and_length = cpu_to_le32(cmd_length);
-- 
1.7.11.4
