From: Bastien Philbert <bastienphilbert@gmail.com>
Subject: [PATCH] ipv6: icmp: Add protection from concurrent users in the function icmpv6_echo_reply
Date: Tue,  5 Apr 2016 17:27:56 -0400
Message-ID: <1459891676-20836-1-git-send-email-bastienphilbert@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds protection from concurrenct users in the function
icmpv6_echo_reply around the call to the function __in6_dev_get
by locking/unlocking around this call with calls to the functions
rtnl_lock and rtnl_unlock to protect against concurrent users
when calling this function in icmpv6_echo_reply as stated in the
comments for locking requirements for the function, __in6_dev_get.

Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
---
 net/ipv6/icmp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 0a37ddc..798434f 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -607,7 +607,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
+	rtnl_lock();
 	idev = __in6_dev_get(skb->dev);
+	rtnl_unlock();
 
 	msg.skb = skb;
 	msg.offset = 0;
-- 
2.5.0
