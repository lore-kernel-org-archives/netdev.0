From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next] qlcnic: remove assumption that vlan_tci != 0
Date: Wed,  4 Jan 2017 01:07:58 +0100 (CET)
Message-ID: <d37e4740f9de22022febb19e499e4f0997aaeb99.1483487887.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37234 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762095AbdADAID (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 19:08:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index fedd7366713c..c3cc707cc265 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -459,7 +459,7 @@ static int qlcnic_tx_pkt(struct qlcnic_adapter *adapter,
 			 struct cmd_desc_type0 *first_desc, struct sk_buff *skb,
 			 struct qlcnic_host_tx_ring *tx_ring)
 {
-	u8 l4proto, opcode = 0, hdr_len = 0;
+	u8 l4proto, opcode = 0, hdr_len = 0, tag_vlan = 0;
 	u16 flags = 0, vlan_tci = 0;
 	int copied, offset, copy_len, size;
 	struct cmd_desc_type0 *hwdesc;
@@ -472,14 +472,16 @@ static int qlcnic_tx_pkt(struct qlcnic_adapter *adapter,
 		flags = QLCNIC_FLAGS_VLAN_TAGGED;
 		vlan_tci = ntohs(vh->h_vlan_TCI);
 		protocol = ntohs(vh->h_vlan_encapsulated_proto);
+		tag_vlan = 1;
 	} else if (skb_vlan_tag_present(skb)) {
 		flags = QLCNIC_FLAGS_VLAN_OOB;
 		vlan_tci = skb_vlan_tag_get(skb);
+		tag_vlan = 1;
 	}
 	if (unlikely(adapter->tx_pvid)) {
-		if (vlan_tci && !(adapter->flags & QLCNIC_TAGGING_ENABLED))
+		if (tag_vlan && !(adapter->flags & QLCNIC_TAGGING_ENABLED))
 			return -EIO;
-		if (vlan_tci && (adapter->flags & QLCNIC_TAGGING_ENABLED))
+		if (tag_vlan && (adapter->flags & QLCNIC_TAGGING_ENABLED))
 			goto set_flags;
 
 		flags = QLCNIC_FLAGS_VLAN_OOB;
-- 
2.11.0
