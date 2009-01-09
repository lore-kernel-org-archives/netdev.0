From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] netdev: missing validate_address hooks
Date: Fri, 9 Jan 2009 12:45:37 -0800
Message-ID: <20090109124537.346c61d8@s6510>
References: <20090109124427.71d15306@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41434 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674AbZAIUqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 15:46:03 -0500
In-Reply-To: <20090109124427.71d15306@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices were converted incorrectly and are missing the validate
address hooks.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/acenic.c	2009-01-08 08:30:09.000000000 -0800
+++ b/drivers/net/acenic.c	2009-01-09 12:40:17.000000000 -0800
@@ -460,6 +460,7 @@ static const struct net_device_ops ace_n
 	.ndo_get_stats		= ace_get_stats,
 	.ndo_start_xmit		= ace_start_xmit,
 	.ndo_set_multicast_list	= ace_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ace_set_mac_addr,
 	.ndo_change_mtu		= ace_change_mtu,
 #if ACENIC_DO_VLAN
--- a/drivers/net/arm/ks8695net.c	2009-01-08 08:30:09.000000000 -0800
+++ b/drivers/net/arm/ks8695net.c	2009-01-09 12:40:37.000000000 -0800
@@ -1357,6 +1357,7 @@ static const struct net_device_ops ks869
 	.ndo_start_xmit		= ks8695_start_xmit,
 	.ndo_tx_timeout		= ks8695_timeout,
 	.ndo_set_mac_address	= ks8695_set_mac,
+	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= ks8695_set_multicast,
 };
 
--- a/drivers/net/mlx4/en_netdev.c	2009-01-08 08:30:12.000000000 -0800
+++ b/drivers/net/mlx4/en_netdev.c	2009-01-09 12:41:47.000000000 -0800
@@ -952,6 +952,7 @@ static const struct net_device_ops mlx4_
 	.ndo_get_stats		= mlx4_en_get_stats,
 	.ndo_set_multicast_list	= mlx4_en_set_multicast,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
+	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= mlx4_en_change_mtu,
 	.ndo_tx_timeout		= mlx4_en_tx_timeout,
 	.ndo_vlan_rx_register	= mlx4_en_vlan_rx_register,
