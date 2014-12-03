From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next v2] ipv6: remove useless spin_lock/spin_unlock
Date: Wed, 3 Dec 2014 10:29:40 +0800
Message-ID: <547E7594.7010301@cn.fujitsu.com>
References: <547E6832.4070403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:64331 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751043AbaLCCcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 21:32:17 -0500
In-Reply-To: <547E6832.4070403@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


xchg is atomic, so there is no necessary to use spin_lock/spin_unlock
to protect it. At last, remove the redundant
opt = xchg(&inet6_sk(sk)->opt, opt); statement.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
v2: remove the redundant opt = xchg(&inet6_sk(sk)->opt, opt); statement.

 net/ipv6/ipv6_sockglue.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index e1a9583..66980d8 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -110,12 +110,8 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 			icsk->icsk_ext_hdr_len = opt->opt_flen + opt->opt_nflen;
 			icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		}
-		opt = xchg(&inet6_sk(sk)->opt, opt);
-	} else {
-		spin_lock(&sk->sk_dst_lock);
-		opt = xchg(&inet6_sk(sk)->opt, opt);
-		spin_unlock(&sk->sk_dst_lock);
 	}
+	opt = xchg(&inet6_sk(sk)->opt, opt);
 	sk_dst_reset(sk);
 
 	return opt;
-- 
1.8.3.1
