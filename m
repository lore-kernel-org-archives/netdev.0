From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: ipv4: add code comment for clarification
Date: Thu, 4 May 2017 14:44:16 -0500
Message-ID: <20170504194415.GA29391@embeddedgus>
References: <20170504142432.Horde.g9y26Ryxbtg1EIl_cnsdbbw@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170504142432.Horde.g9y26Ryxbtg1EIl_cnsdbbw@gator4166.hostgator.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add code comment to make it clear that the position of the arguments
req->id.idiag_dport and req->id.idiag_sport is a locked in behavior
and it should not be changed.

Addresses-Coverity-ID: 1357474
Cc: David Miller <davem@davemloft.net>
Cc: Joe Perches <joe@perches.com>
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/ipv4/inet_diag.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 3828b3a..841800b 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -389,6 +389,12 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 				  nlmsg_flags, unlh, net_admin);
 }
 
+/*
+ * Ignore the position of the arguments req->id.idiag_dport and
+ * req->id.idiag_sport in both calls to inet_lookup() and inet6_lookup()
+ * functions, once this is a locked in behavior exposed to user space.
+ * Changing this will break things for people.
+ */
 struct sock *inet_diag_find_one_icsk(struct net *net,
 				     struct inet_hashinfo *hashinfo,
 				     const struct inet_diag_req_v2 *req)
-- 
2.5.0
