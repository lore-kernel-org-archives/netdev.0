From: Boris Ostrovsky <ostr@amd64.org>
Subject: [PATCH] ipv6: Don't pass invalid dst_entry pointer to dst_release().
Date: Mon,  4 Apr 2011 15:55:10 -0400
Message-ID: <1301946910-5530-1-git-send-email-ostr@amd64.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Boris Ostrovsky <boris.ostrovsky@amd.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Boris Ostrovsky <boris.ostrovsky@amd.com>

Make sure dst_release() is not called with error pointer. This is
similar to commit 4910ac6c526d2868adcb5893e0c428473de862b5.

Signed-off-by: Boris Ostrovsky <boris.ostrovsky@amd.com>
---
 net/ipv6/tcp_ipv6.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b0c186..56fa125 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -503,6 +503,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
+		dst = NULL;
 		goto done;
 	}
 	skb = tcp_make_synack(sk, dst, req, rvp);
-- 
1.7.1
