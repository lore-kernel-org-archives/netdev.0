From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/2] Revert "l2tp: constify inet6_protocol structures"
Date: Tue,  1 Aug 2017 18:27:29 +0200
Message-ID: <1501604849-19443-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1501604849-19443-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, bhumirks@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501604849-19443-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit d04916a48ad4a3db892b664fa9c3a2a693c378ad.

inet6_add_protocol and inet6_del_protocol include casts that remove the
effect of the const annotation on their parameter, leading to possible
runtime crashes.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

 net/l2tp/l2tp_ip6.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index d2efcd9..88b397c 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -788,7 +788,7 @@ static int l2tp_ip6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	.ops		= &l2tp_ip6_ops,
 };
 
-static const struct inet6_protocol l2tp_ip6_protocol = {
+static struct inet6_protocol l2tp_ip6_protocol __read_mostly = {
 	.handler	= l2tp_ip6_recv,
 };
 
