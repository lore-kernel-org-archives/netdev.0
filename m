From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/33] netdev: network device operations infrastructure
Date: Wed, 19 Nov 2008 21:27:16 -0800 (PST)
Message-ID: <20081119.212716.85235118.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234354.864259203@vyatta.com>
	<20081119.212650.102527885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752962AbYKTF1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:27:16 -0500
In-Reply-To: <20081119.212650.102527885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 19 Nov 2008 21:26:50 -0800 (PST)

> Ok, I'm applying this but it needs the following interdiff to cure some
> build failures.

Durrr!  And here is that interdiff!

--- net/core/dev.c~	2008-11-19 17:36:28.000000000 -0800
+++ net/core/dev.c	2008-11-19 17:36:56.000000000 -0800
@@ -4037,7 +4037,9 @@ int register_netdevice(struct net_device
 		dev->vlan_rx_register = ops->vlan_rx_register;
 		dev->vlan_rx_add_vid = ops->vlan_rx_add_vid;
 		dev->vlan_rx_kill_vid = ops->vlan_rx_kill_vid;
+#ifdef CONFIG_NET_POLL_CONTROLLER
 		dev->poll_controller = ops->poll_controller;
+#endif
 	} else {
 		char drivername[64];
 		pr_info("%s (%s): not using net_device_ops yet\n",
