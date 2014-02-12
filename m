From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] net: allow setting mac address of loopback device
Date: Tue, 11 Feb 2014 17:21:26 -0800
Message-ID: <1392168086-25607-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:44153 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbaBLBVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:21:40 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so8268209pdj.17
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 17:21:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are trying to mirror the local traffic from lo to eth0,
allowing setting mac address of lo to eth0 would make
the ether addresses in these packets correct, so that
we don't have to modify the ether header again.

Since usually no one cares about its mac address (all-zero),
it is safe to allow those who care to set its mac address.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c5011e0..e7c1d5f 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -160,6 +160,7 @@ static const struct net_device_ops loopback_ops = {
 	.ndo_init      = loopback_dev_init,
 	.ndo_start_xmit= loopback_xmit,
 	.ndo_get_stats64 = loopback_get_stats64,
+	.ndo_set_mac_address = eth_mac_addr,
 };
 
 /*
@@ -174,6 +175,7 @@ static void loopback_setup(struct net_device *dev)
 	dev->tx_queue_len	= 0;
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
+	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
 	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
