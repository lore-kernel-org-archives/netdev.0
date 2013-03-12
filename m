From: roy.qing.li@gmail.com
Subject: [PATCH net-next] net/core: move vlan_depth out of while loop in skb_network_protocol()
Date: Tue, 12 Mar 2013 14:30:44 +0800
Message-ID: <1363069844-10624-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:48573 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659Ab3CLGaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 02:30:52 -0400
Received: by mail-ie0-f177.google.com with SMTP id 16so5914097iea.22
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 23:30:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

move vlan_depth out of while loop, or else vlan_depth always is ETH_HLEN,
can not be increased, and lead to infinite loop when frame has two vlan headers.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 90cee5b..35a6a6e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2211,9 +2211,9 @@ EXPORT_SYMBOL(skb_checksum_help);
 __be16 skb_network_protocol(struct sk_buff *skb)
 {
 	__be16 type = skb->protocol;
+	int vlan_depth = ETH_HLEN;
 
 	while (type == htons(ETH_P_8021Q)) {
-		int vlan_depth = ETH_HLEN;
 		struct vlan_hdr *vh;
 
 		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
-- 
1.7.10.4
