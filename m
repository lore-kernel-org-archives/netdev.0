From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [BUILD FAILURE 06/12] Next April 14 : PPC64 randconfig
	[drivers/net/ehea/ehea_main.c]
Date: Tue, 14 Apr 2009 22:39:38 +0400
Message-ID: <20090414183938.GA17134@orion>
References: <1239733747.5344.78.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linuxppc-dev <Linuxppc-dev@ozlabs.org>, Greg KH <greg@kroah.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, Julia Lawall <julia@diku.dk>,
	Jeff Garzik <jgarzik@pobox.com>, Mel Gorman <mel@skynet.ie>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	sachinp <sachinp@linux.vnet.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-net <linux-net@vger.kernel.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Subrata Modak <subrata@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:36847 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbZDNSkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 14:40:04 -0400
Content-Disposition: inline
In-Reply-To: <1239733747.5344.78.camel@subratamodak.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 11:59:07PM +0530, Subrata Modak wrote:
> Observed the following build error:
> CC      drivers/net/ehea/ehea_main.o
> drivers/net/ehea/ehea_main.c: In function ???ehea_setup_single_port???:
> drivers/net/ehea/ehea_main.c:3145: error: ???struct net_device??? has no
> member named ???tx_timeout???

>From 56142fa2ed992aeee3f2635990ac37807379a310 Mon Sep 17 00:00:00 2001
From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Tue, 14 Apr 2009 22:35:32 +0400
Subject: [PATCH] ehea: Fix incomplete conversion to net_device_ops


Reported-by: Subrata Modak <subrata@linux.vnet.ibm.com>
Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/ehea/ehea_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index ac0c5b4..604c844 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3080,7 +3080,8 @@ static const struct net_device_ops ehea_netdev_ops = {
 	.ndo_change_mtu		= ehea_change_mtu,
 	.ndo_vlan_rx_register	= ehea_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ehea_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= ehea_vlan_rx_kill_vid
+	.ndo_vlan_rx_kill_vid	= ehea_vlan_rx_kill_vid,
+	.ndo_tx_timeout		= ehea_tx_watchdog,
 };
 
 struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
@@ -3142,7 +3143,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_LLTX;
-	dev->tx_timeout = &ehea_tx_watchdog;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
-- 
1.6.2.3

