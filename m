From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6][DRIVER][VETH] fix dev refcount race
Date: Wed, 20 Feb 2008 00:22:10 -0800 (PST)
Message-ID: <20080220.002210.103312359.davem@davemloft.net>
References: <47BB0138.1000104@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57598
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752469AbYBTIVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 03:21:33 -0500
In-Reply-To: <47BB0138.1000104@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Tue, 19 Feb 2008 17:18:00 +0100

> veth: fix dev refcount race
> 
> When deleting the veth driver, veth_close calls netif_carrier_off
> for the two extremities of the network device. netif_carrier_off on
> the peer device will fire an event and hold a reference on the peer
> device. Just after, the peer is unregistered taking the rtnl_lock while
> the linkwatch_event is scheduled. If __linkwatch_run_queue does not
> occurs before the unregistering, unregister_netdevice will wait for
> the dev refcount to reach zero holding the rtnl_lock and linkwatch_event
> will wait for the rtnl_lock and hold the dev refcount.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Thank you for fixing this bug, patch applied.
