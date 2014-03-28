From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/14] igb: never generate both software and hardware timestamps
Date: Fri, 28 Mar 2014 07:08:14 -0700
Message-ID: <1396015695-25283-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17012 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752452AbaC1OJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 10:09:13 -0400
In-Reply-To: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

skb_tx_timestamp() does not report software time stamp
if SKBTX_IN_PROGRESS is set. According to timestamping.txt
software time stamps are a fallback and should not be
generated if hardware time stamp is provided.

Move call to skb_tx_timestamp() after setting
SKBTX_IN_PROGRESS.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index cd20409..1fdffa2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4980,8 +4980,6 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	first->bytecount = skb->len;
 	first->gso_segs = 1;
 
-	skb_tx_timestamp(skb);
-
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 
@@ -4996,6 +4994,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 		}
 	}
 
+	skb_tx_timestamp(skb);
+
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IGB_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << IGB_TX_FLAGS_VLAN_SHIFT);
-- 
1.9.0
