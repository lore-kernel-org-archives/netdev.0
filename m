From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2 1/2] ip_tunnel: fix ip tunnel lookup in collect_md mode
Date: Sat, 17 Jun 2017 11:27:10 +0800
Message-ID: <1497670031-2971-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Pravin B Shelar <pshelar@nicira.com>
To: "David S. Miller" <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In collect_md mode, if the tun dev is down, it still can call
ip_tunnel_rcv to receive on packets, and the rx statistics increase
improperly.

Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Change since v2:
  * Fix wrong recipient addresss
---
 net/ipv4/ip_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0f1d876..a3caba1 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -176,7 +176,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		return cand;
 
 	t = rcu_dereference(itn->collect_md_tun);
-	if (t)
+	if (t && (t->dev->flags & IFF_UP))
 		return t;
 
 	if (itn->fb_tunnel_dev && itn->fb_tunnel_dev->flags & IFF_UP)
-- 
1.8.3.1
