From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v4 1/2] ip_tunnel: fix ip tunnel lookup in collect_md mode
Date: Tue, 12 Sep 2017 17:47:56 +0800
Message-ID: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Pravin B Shelar <pshelar@nicira.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In collect_md mode, if the tun dev is down, it still can call
ip_tunnel_rcv to receive on packets, and the rx statistics increase
improperly.

When the md tunnel is down, it's not neccessary to increase RX drops
for the tunnel device, packets would be recieved on fallback tunnel,
and the RX drops on fallback device will be increased as expected.

Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Change since v4:
  * Make the commit message more clearer.
  * Fix wrong recipient addresss
---
 net/ipv4/ip_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e1856bf..e9805ad 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -176,7 +176,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		return cand;
 
 	t = rcu_dereference(itn->collect_md_tun);
-	if (t)
+	if (t && t->dev->flags & IFF_UP)
 		return t;
 
 	if (itn->fb_tunnel_dev && itn->fb_tunnel_dev->flags & IFF_UP)
-- 
1.8.3.1
