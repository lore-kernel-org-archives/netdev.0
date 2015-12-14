From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net] skbuff: Fix offset error in skb_reorder_vlan_header
Date: Mon, 14 Dec 2015 17:44:10 -0500
Message-ID: <1450133050-24636-1-git-send-email-vyasevich@gmail.com>
References: <566ED772.8070600@6wind.com>
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35948 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932470AbbLNWpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 17:45:23 -0500
Received: by qkht125 with SMTP id t125so160154420qkh.3
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 14:45:23 -0800 (PST)
In-Reply-To: <566ED772.8070600@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_reorder_vlan_header is called after the vlan header has
been pulled.  As a result the offset of the begining of
the mac header has been incrased by 4 bytes (VLAN_HLEN).
When moving the mac addresses, include this incrase in
the offset calcualation so that the mac addresses are
copied correctly.

Fixes: a6e18ff1117 (vlan: Fix untag operations of stacked vlans with REORDER_HEADER off)
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 152b9c7..5cc43d37 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4268,7 +4268,7 @@ static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
 		return NULL;
 	}
 
-	memmove(skb->data - ETH_HLEN, skb->data - skb->mac_len,
+	memmove(skb->data - ETH_HLEN, skb->data - skb->mac_len - VLAN_HLEN,
 		2 * ETH_ALEN);
 	skb->mac_header += VLAN_HLEN;
 	return skb;
-- 
2.1.0
