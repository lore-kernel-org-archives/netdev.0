From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 04 Mar 2009 23:00:23 -0800 (PST)
Message-ID: <20090304.230023.09984572.davem@davemloft.net>
References: <20090304.195328.106253933.davem@davemloft.net>
	<49AF685D.90907@trash.net>
	<20090304.225719.159854470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50169
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751933AbZCEHAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 02:00:38 -0500
In-Reply-To: <20090304.225719.159854470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think this will fix it.

diff --git a/net/core/dev.c b/net/core/dev.c
index 9e4afe6..2dd484e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4339,6 +4339,7 @@ int register_netdevice(struct net_device *dev)
 		dev->do_ioctl = ops->ndo_do_ioctl;
 		dev->set_config = ops->ndo_set_config;
 		dev->change_mtu = ops->ndo_change_mtu;
+		dev->neigh_setup = ops->ndo_neigh_setup;
 		dev->tx_timeout = ops->ndo_tx_timeout;
 		dev->get_stats = ops->ndo_get_stats;
 		dev->vlan_rx_register = ops->ndo_vlan_rx_register;
