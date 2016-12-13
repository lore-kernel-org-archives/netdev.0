From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 04/27] qlcnic: remove assumption that vlan_tci != 0
Date: Tue, 13 Dec 2016 01:12:33 +0100 (CET)
Message-ID: <5d3454e83ea712ce809f2f6f7c8b4465c7df83b4.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Harish Patil <harish.patil@cavium.com> (supporter:QLOGIC QLCNIC
        (1/10)Gb ETHERNET DRIVER),
        Manish Chopra <manish.chopra@cavium.com> (supporter:QLOGIC QLCNIC
        (1/10)Gb ETHERNET DRIVER),
        Dept-GELinuxNICDev@cavium.com (supporter:QLOGIC QLCNIC (1/10)Gb
        ETHERNET DRIVER)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50198 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752844AbcLMAMg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:36 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index fedd736..c3cc707 100644
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
2.10.2
