From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: [PATCH] netlink: switch net_ns only if net is not init_net
Date: Fri, 07 Mar 2014 18:47:30 +0800
Message-ID: <5319A3C2.8080001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many netlink users create netlink sock in the init_net, and the
switching nes_ns(init_net-->net) is needless in this case. So here
we add a pre-check to avoid this.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 net/netlink/af_netlink.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index fdf5135..e9e4be9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2429,7 +2429,8 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 		goto out_sock_release_nosk;
 
 	sk = sock->sk;
-	sk_change_net(sk, net);
+	if (!net_eq(net, &init_net))
+		sk_change_net(sk, net);
 
 	if (!cfg || cfg->groups < 32)
 		groups = 32;
-- 
1.7.7
