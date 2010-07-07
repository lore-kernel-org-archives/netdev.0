From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vlan: allow TSO setting on vlan interfaces
Date: Wed, 07 Jul 2010 19:14:34 +0200
Message-ID: <1278522874.5906.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41051 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556Ab0GGROj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 13:14:39 -0400
Received: by wyf23 with SMTP id 23so3420016wyf.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 10:14:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we need to shape traffic with low speeds, we need to disable tso on
network interface :

ethtool -K eth0.2240 tso off

It seems vlan interfaces miss the set_tso() ethtool method.
Propagating tso changes from lower device is not always wanted, some
vlan want TSO on, other want TSO off.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c6456cb..d827c2e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -844,6 +844,7 @@ static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_rx_csum		= vlan_ethtool_get_rx_csum,
 	.get_flags		= vlan_ethtool_get_flags,
+	.set_tso		= ethtool_op_set_tso,
 };
 
 static const struct net_device_ops vlan_netdev_ops = {


