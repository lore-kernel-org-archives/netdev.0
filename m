From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] ipvlan: inherit MTU from master device
Date: Wed, 27 Jan 2016 23:33:28 -0800
Message-ID: <1453966408-16343-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Tim Hockin <thockin@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tim Hockins <thockins@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34232 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbcA1Hdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 02:33:35 -0500
Received: by mail-pa0-f66.google.com with SMTP id yy13so1562211pab.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 23:33:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

When we create IPvlan slave; we use ether_setup() and that
sets up default MTU to 1500 while the master device may have
lower / different MTU. Any subsequent changes to the masters'
MTU are reflected into the slaves' MTU setting. However if those
don't happen (most likely scenario), the slaves' MTU stays at
1500 which could be bad.

This change adds code to inherit MTU from the master device
instead of using the default value during the link initialization
phase.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tim Hockins <thockins@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index f94392d07126..7a3b41468a55 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -468,6 +468,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	ipvlan->dev = dev;
 	ipvlan->port = port;
 	ipvlan->sfeatures = IPVLAN_FEATURES;
+	ipvlan_adjust_mtu(ipvlan, phy_dev);
 	INIT_LIST_HEAD(&ipvlan->addrs);
 
 	/* TODO Probably put random address here to be presented to the
-- 
2.7.0.rc3.207.g0ac5344
