From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] netpoll: slight optimization for netpoll_neigh_reply
Date: Mon, 17 Mar 2014 15:09:47 +0800
Message-ID: <1395040188-24840-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47256 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000AbaCQHJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 03:09:53 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so5309561pab.22
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 00:09:53 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id qq5sm40386541pbb.24.2014.03.17.00.09.50
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 00:09:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

'hits' is used to check If there is a device who is interested
in this skb, not care the device number, so stop the loop once
a device is found

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/netpoll.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index dd0a796..9a276e6 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -545,8 +545,10 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 	   inspection whether this is interesting at all */
 	spin_lock_irqsave(&npinfo->rx_lock, flags);
 	list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-		if (np->dev == skb->dev)
+		if (np->dev == skb->dev) {
 			hits++;
+			break;
+		}
 	}
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 
-- 
1.7.10.4
