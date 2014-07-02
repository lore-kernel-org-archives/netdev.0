From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix sparse warning in sk_dst_set()
Date: Wed, 02 Jul 2014 02:39:38 -0700
Message-ID: <1404293978.23797.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60473 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaGBJjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 05:39:41 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so9261171wib.17
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 02:39:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sk_dst_cache has __rcu annotation, so we need a cast to avoid
following sparse error :

include/net/sock.h:1774:19: warning: incorrect type in initializer (different address spaces)
include/net/sock.h:1774:19:    expected struct dst_entry [noderef] <asn:4>*__ret
include/net/sock.h:1774:19:    got struct dst_entry *dst

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 7f502361531e ("ipv4: irq safe sk_dst_[re]set() and ipv4_sk_update_pmtu() fix")
---
 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c556fd9b05ac..156350745700 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1771,7 +1771,7 @@ sk_dst_set(struct sock *sk, struct dst_entry *dst)
 	struct dst_entry *old_dst;
 
 	sk_tx_queue_clear(sk);
-	old_dst = xchg(&sk->sk_dst_cache, dst);
+	old_dst = xchg((__force struct dst_entry **)&sk->sk_dst_cache, dst);
 	dst_release(old_dst);
 }
 
