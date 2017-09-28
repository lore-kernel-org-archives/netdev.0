From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ip_gre: ipgre_tap device should keep dst
Date: Thu, 28 Sep 2017 13:23:31 +0800
Message-ID: <af0a18f43bc27a26ca1f3bce3730edcb312c9f76.1506576211.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33270 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdI1FXk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 01:23:40 -0400
Received: by mail-pg0-f67.google.com with SMTP id u136so679613pgc.0
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 22:23:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without keeping dst, the tunnel will not update any mtu/pmtu info,
since it does not have a dst on the skb.

Reproducer:
  client(ipgre_tap1 - eth1) <-----> (eth1 - ipgre_tap1)server

After reducing eth1's mtu on client, then perforamnce became 0.

This patch is to netif_keep_dst in gre_tap_init, as ipgre does.

Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0162fb9..8b837f6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1223,6 +1223,7 @@ static int gre_tap_init(struct net_device *dev)
 {
 	__gre_tunnel_init(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	netif_keep_dst(dev);
 
 	return ip_tunnel_init(dev);
 }
-- 
2.1.0
