From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 4/4] ip_gre: erspan device should keep dst
Date: Sun,  1 Oct 2017 22:00:56 +0800
Message-ID: <c6fb2477718ad64f7c2d9a3704550a6cbcdbb87a.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
 <ef4c0ca4a1f0b6ae6eabda22fd9f55d0173fa862.1506866059.git.lucien.xin@gmail.com>
 <54a772dbf163eacd65d846054a63f8f7a87e318b.1506866059.git.lucien.xin@gmail.com>
 <dcf4c8a2af505c0e29dfa4b70215560f6ad591ca.1506866059.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>,
        William Tu <u9012063@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33948 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751021AbdJAOBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 10:01:38 -0400
Received: by mail-pg0-f68.google.com with SMTP id u27so3163670pgn.1
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 07:01:38 -0700 (PDT)
In-Reply-To: <dcf4c8a2af505c0e29dfa4b70215560f6ad591ca.1506866059.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 'ip_gre: ipgre_tap device should keep dst' fixed
the issue ipgre_tap dev mtu couldn't be updated in tx path.

The same fix is needed for erspan as well.

Fixes: 84e54fe0a5ea ("gre: introduce native tunnel support for ERSPAN")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fad0bb1..467e44d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1254,6 +1254,7 @@ static int erspan_tunnel_init(struct net_device *dev)
 	dev->features		|= GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
 	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
+	netif_keep_dst(dev);
 
 	return ip_tunnel_init(dev);
 }
-- 
2.1.0
