From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] via-rhine: trivial sparse annotation in vlan_tci helper
Date: Mon, 28 Mar 2011 20:08:59 -0700
Message-ID: <1301368139-2489-1-git-send-email-harvey.harrison@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:34116 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181Ab1C2DUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 23:20:45 -0400
Received: by pvg12 with SMTP id 12so609650pvg.19
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 20:20:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed by sparse:
drivers/net/via-rhine.c:1706:16: warning: cast to restricted __be16

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/via-rhine.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 5e7f069..707f7f8 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1703,7 +1703,7 @@ static void rhine_tx(struct net_device *dev)
 static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size)
 {
 	u8 *trailer = (u8 *)skb->data + ((data_size + 3) & ~3) + 2;
-	return ntohs(*(u16 *)trailer);
+	return be16_to_cpup((__be16 *)trailer);
 }
 
 /* Process up to limit frames from receive ring */
-- 
1.7.4

