From: fgao@ikuai8.com
Subject: [PATCH net 1/1] net: l2tp: Treat NET_XMIT_CN as success in l2tp_eth_dev_xmit
Date: Mon, 21 Nov 2016 08:56:21 +0800
Message-ID: <1479689781-2125-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com
To: edumazet@google.com, davem@davemloft.net, javier@osg.samsung.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg278.qq.com ([113.108.11.203]:52442 "EHLO smtpbg278.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751302AbcKUA5O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Nov 2016 19:57:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

The tc could return NET_XMIT_CN as one congestion notification, but
it does not mean the packe is lost. Other modules like ipvlan,
macvlan, and others treat NET_XMIT_CN as success too.
So l2tp_eth_dev_xmit should add the NET_XMIT_CN check.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
---
 net/l2tp/l2tp_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 965f7e3..3dc97b4 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -97,7 +97,7 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len = skb->len;
 	int ret = l2tp_xmit_skb(session, skb, session->hdr_len);
 
-	if (likely(ret == NET_XMIT_SUCCESS)) {
+	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		atomic_long_add(len, &priv->tx_bytes);
 		atomic_long_inc(&priv->tx_packets);
 	} else {
-- 
1.9.1
