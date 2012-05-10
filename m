From: alex.bluesman.smirnov@gmail.com
Subject: [PATCH 1/2 net] 6lowpan: add missing pskb_may_pull() check
Date: Thu, 10 May 2012 17:22:42 +0400
Message-ID: <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
References: <1336656163-19382-1-git-send-email-y>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48355 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716Ab2EJNXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 09:23:51 -0400
Received: by bkcji2 with SMTP id ji2so1280937bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 06:23:50 -0700 (PDT)
In-Reply-To: <1336656163-19382-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Add pskb_may_pull() call when fetching u8 from skb.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 32eb417..0ab3efe 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -295,6 +295,8 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff *skb)
 {
 	u8 ret;
 
+	BUG_ON(!pskb_may_pull(skb, 1));
+
 	ret = skb->data[0];
 	skb_pull(skb, 1);
 
-- 
1.7.2.3
