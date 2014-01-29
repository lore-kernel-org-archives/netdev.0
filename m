From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: allow setting mac address of loopback device
Date: Wed, 29 Jan 2014 15:38:51 -0800
Message-ID: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:35721 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaA2XjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 18:39:07 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so2404456pbb.3
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 15:39:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are trying to mirror the local traffic from lo to eth0,
allowing setting mac address of lo to eth0 would make
the ether addresses in these packets correct, so that
we don't have to modify the ether header again.

Since usually no one cares about its mac address (all-zero),
it is safe to allow those who care to set its mac address.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c5011e0..a0ee030 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -160,6 +160,7 @@ static const struct net_device_ops loopback_ops = {
 	.ndo_init      = loopback_dev_init,
 	.ndo_start_xmit= loopback_xmit,
 	.ndo_get_stats64 = loopback_get_stats64,
+	.ndo_set_mac_address = eth_mac_addr,
 };
 
 /*
