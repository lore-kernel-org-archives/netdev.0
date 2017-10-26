From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] Revert "rtnetlink: check DO_SETLINK_NOTIFY correctly in do_setlink"
Date: Thu, 26 Oct 2017 10:21:53 +0200
Message-ID: <20171026082153.8042-1-nicolas.dichtel@6wind.com>
References: <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        vyasevic@redhat.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Ahern <dsahern@gmail.com>,
        Xin Long <lucien.xin@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:33248 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932162AbdJZIWr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:22:47 -0400
In-Reply-To: <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 64ff90cc2e6f42596d7a0c37e41dc95292bb63b1.

The initial test was right. The goal is to advertised any modifications of
any setting of a link. The test ensures that the user won't lose an update.

CC: David Ahern <dsahern@gmail.com>
CC: Xin Long <lucien.xin@gmail.com>
Reported-by: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5ace48926b19..52689c399b6c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2251,7 +2251,7 @@ static int do_setlink(const struct sk_buff *skb,
 
 errout:
 	if (status & DO_SETLINK_MODIFIED) {
-		if ((status & DO_SETLINK_NOTIFY) == DO_SETLINK_NOTIFY)
+		if (status & DO_SETLINK_NOTIFY)
 			netdev_state_change(dev);
 
 		if (err < 0)
-- 
2.13.2
