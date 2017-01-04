From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 2/8] benet: use skb_vlan_tag_get_prio()
Date: Wed,  4 Jan 2017 01:24:25 +0100 (CET)
Message-ID: <bfbbd585f6972360ee1cd15d65a80d0b8c654385.1483488960.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483488960.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37468 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965335AbdADAY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 19:24:28 -0500
In-Reply-To: <cover.1483488960.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index cd12c9a7664b..7e50c6c224c4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -781,7 +781,7 @@ static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
 	u16 vlan_tag;
 
 	vlan_tag = skb_vlan_tag_get(skb);
-	vlan_prio = (vlan_tag & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+	vlan_prio = skb_vlan_tag_get_prio(skb);
 	/* If vlan priority provided by OS is NOT in available bmap */
 	if (!(adapter->vlan_prio_bmap & (1 << vlan_prio)))
 		vlan_tag = (vlan_tag & ~VLAN_PRIO_MASK) |
-- 
2.11.0
