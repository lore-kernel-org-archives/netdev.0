From: Ivan Vecera <ivecera@redhat.com>
Subject: [net PATCH] be2net: take care of __vlan_put_tag return value
Date: Fri, 12 Apr 2013 16:49:24 +0200
Message-ID: <1365778164-16857-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603Ab3DLOt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 10:49:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver should use return value of __vlan_put_tag with appropriate
NULL-check instead of old skb pointer.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4d6f3c5..a4e4626 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -759,8 +759,9 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 
 	if (vlan_tx_tag_present(skb)) {
 		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
-		__vlan_put_tag(skb, vlan_tag);
-		skb->vlan_tci = 0;
+		skb = __vlan_put_tag(skb, vlan_tag);
+		if (skb)
+			skb->vlan_tci = 0;
 	}
 
 	return skb;
-- 
1.8.1.5
