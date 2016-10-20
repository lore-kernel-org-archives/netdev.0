From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH] net: l2tp_eth: fix max_mtu
Date: Thu, 20 Oct 2016 20:08:26 +0000
Message-ID: <20161020200826.24578-1-asbjorn@asbjorn.st>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jarod Wilson <jarod@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes: 61e84623ace3 ("net: centralize net_device min/max MTU checking")
CC: netdev@vger.kernel.org
CC: Jarod Wilson <jarod@redhat.com>
Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 net/l2tp/l2tp_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 965f7e3..ba82dcc 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -259,6 +259,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 		session->mtu = dev->mtu - session->hdr_len;
 	dev->mtu = session->mtu;
 	dev->needed_headroom += session->hdr_len;
+	dev->max_mtu = ETH_MAX_MTU - dev->needed_headroom;
 
 	priv = netdev_priv(dev);
 	priv->dev = dev;
-- 
2.9.3
