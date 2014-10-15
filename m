From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/3] ipv4: call __ip_options_echo() in cookie_v4_check()
Date: Wed, 15 Oct 2014 14:33:20 -0700
Message-ID: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57498 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaJOVdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 17:33:33 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so2030360pab.23
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 14:33:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

commit 971f10eca186cab238c49da ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
missed that cookie_v4_check() still calls ip_options_echo() which uses
IPCB(). It should use TCPCB() at TCP layer, so call __ip_options_echo()
instead.

Fixes: commit 971f10eca186cab238c49da ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
Cc: Eric Dumazet <edumazet@google.com>
Reported-by: Krzysztof Kolasa <kkolasa@winsoft.pl>
Tested-by: Krzysztof Kolasa <kkolasa@winsoft.pl>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/syncookies.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 0431a8f..7e7401c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -321,7 +321,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		int opt_size = sizeof(struct ip_options_rcu) + opt->optlen;
 
 		ireq->opt = kmalloc(opt_size, GFP_ATOMIC);
-		if (ireq->opt != NULL && ip_options_echo(&ireq->opt->opt, skb)) {
+		if (ireq->opt != NULL && __ip_options_echo(&ireq->opt->opt, skb, opt)) {
 			kfree(ireq->opt);
 			ireq->opt = NULL;
 		}
-- 
1.8.3.1
