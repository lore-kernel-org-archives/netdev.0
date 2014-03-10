From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: [PATCH] net: add a pre-check of net_ns in sk_change_net()
Date: Mon, 10 Mar 2014 09:57:34 +0800
Message-ID: <531D1C0E.6010507@cn.fujitsu.com>
References: <5319A3C2.8080001@cn.fujitsu.com> <20140309.190941.472588800498066811.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140309.190941.472588800498066811.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We do not need to switch the net_ns if the target net_ns the same
as the current one, so here we add a pre-check of net_ns to avoid
this as David suggested.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 include/net/sock.h |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5c3f7c3..9678569 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2252,8 +2252,12 @@ void sock_net_set(struct sock *sk, struct net *net)
  */
 static inline void sk_change_net(struct sock *sk, struct net *net)
 {
-	put_net(sock_net(sk));
-	sock_net_set(sk, hold_net(net));
+	struct net *current_net = sock_net(sk);
+
+	if (!net_eq(current_net, net)) {
+		put_net(current_net);
+		sock_net_set(sk, hold_net(net));
+	}
 }
 
 static inline struct sock *skb_steal_sock(struct sk_buff *skb)
-- 
1.7.7
