From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ip6_gre: ip6gre_tap device should keep dst
Date: Thu, 28 Sep 2017 13:23:50 +0800
Message-ID: <0078656bd7917cd981210dfc89807a0728310b48.1506576230.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34193 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdI1FX7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 01:23:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id u18so674808pgo.1
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 22:23:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 'ip_gre: ipgre_tap device should keep dst' fixed
a issue that ipgre_tap mtu couldn't be updated in tx path.

The same fix is needed for ip6gre_tap as well.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ip6_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 20f66f4..1602b49 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1311,6 +1311,7 @@ static void ip6gre_tap_setup(struct net_device *dev)
 	dev->features |= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	netif_keep_dst(dev);
 }
 
 static bool ip6gre_netlink_encap_parms(struct nlattr *data[],
-- 
2.1.0
