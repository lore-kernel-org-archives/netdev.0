From: Tim Hansen <devtimhansen@gmail.com>
Subject: [PATCH] net/ipv6: remove unused err variable on
 icmpv6_push_pending_frames
Date: Thu, 5 Oct 2017 15:45:32 -0400
Message-ID: <20171005194532.GA126147@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com, devtimhansen@gmail.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

int err is unused by icmpv6_push_pending_frames(), this patch returns removes the variable and returns the function with 0.

git bisect shows this variable has been around since linux has been in git in commit 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2.  

This was found by running make coccicheck M=net/ipv6/ on linus' tree on commit 77ede3a014a32746002f7889211f0cecf4803163 (current HEAD as of this patch).

Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
---
 net/ipv6/icmp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 5acb544..aeb49b4 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -255,7 +255,6 @@ int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 {
 	struct sk_buff *skb;
 	struct icmp6hdr *icmp6h;
-	int err = 0;
 
 	skb = skb_peek(&sk->sk_write_queue);
 	if (!skb)
@@ -288,7 +287,7 @@ int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 	}
 	ip6_push_pending_frames(sk);
 out:
-	return err;
+	return 0;
 }
 
 struct icmpv6_msg {
-- 
2.1.4
