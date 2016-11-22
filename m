From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: revert "net: l2tp: Treat NET_XMIT_CN as success in l2tp_eth_dev_xmit"
Date: Mon, 21 Nov 2016 23:24:43 -0800
Message-ID: <1479799483-18332-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Gao Feng <gfree.wind@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34544 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbcKVH0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 02:26:51 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so1293014pgc.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 23:26:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 7c6ae610a1f0, because l2tp_xmit_skb() never
returns NET_XMIT_CN, it ignores the return value of l2tp_xmit_core().

Cc: Gao Feng <gfree.wind@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/l2tp/l2tp_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 3dc97b4..965f7e3 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -97,7 +97,7 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len = skb->len;
 	int ret = l2tp_xmit_skb(session, skb, session->hdr_len);
 
-	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
+	if (likely(ret == NET_XMIT_SUCCESS)) {
 		atomic_long_add(len, &priv->tx_bytes);
 		atomic_long_inc(&priv->tx_packets);
 	} else {
-- 
1.8.4.5
