From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/2] l2tp: constify inet6_protocol structures
Date: Fri, 28 Jul 2017 22:18:58 +0200
Message-ID: <1501273138-22771-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, bhumirks@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The inet6_protocol structure is only passed as the first argument to
inet6_add_protocol or inet6_del_protocol, both of which are declared as
const.  Thus the inet6_protocol structure itself can be const.

Also drop __read_mostly on the newly const structure.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/l2tp/l2tp_ip6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 88b397c..d2efcd9 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -788,7 +788,7 @@ static int l2tp_ip6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	.ops		= &l2tp_ip6_ops,
 };
 
-static struct inet6_protocol l2tp_ip6_protocol __read_mostly = {
+static const struct inet6_protocol l2tp_ip6_protocol = {
 	.handler	= l2tp_ip6_recv,
 };
 
