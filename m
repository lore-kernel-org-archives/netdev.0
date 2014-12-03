From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] ipv6: remove useless spin_lock/spin_unlock
Date: Wed, 3 Dec 2014 09:32:34 +0800
Message-ID: <547E6832.4070403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:44208 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751157AbaLCBfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 20:35:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


xchg is atomic, so there is no necessary to use spin_lock/spin_unlock
to protect it.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index e1a9583..92ca907 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -112,9 +112,7 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 		}
 		opt = xchg(&inet6_sk(sk)->opt, opt);
 	} else {
-		spin_lock(&sk->sk_dst_lock);
 		opt = xchg(&inet6_sk(sk)->opt, opt);
-		spin_unlock(&sk->sk_dst_lock);
 	}
 	sk_dst_reset(sk);
 
-- 
1.8.3.1
