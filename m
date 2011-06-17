From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/7] qlcnic: fix default operating state of
 interface
Date: Fri, 17 Jun 2011 00:10:35 -0400 (EDT)
Message-ID: <20110617.001035.1602476678651330954.davem@davemloft.net>
References: <1308256659-19895-1-git-send-email-anirban.chakraborty@qlogic.com>
	<1308256659-19895-5-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amit.salecha@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab1FQEKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:10:39 -0400
In-Reply-To: <1308256659-19895-5-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Thu, 16 Jun 2011 13:37:36 -0700

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> Currently interface shows status as RUNNING, even if there is no link.
> To fix this, netif_carrier_off should be called after register_netdev().
> 
> netif_carrier_off calls linkwatch_fire_event(dev); only if netdev is registered,
> otherwise it skips. linkwatch_fire_event set default state of nic interface.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

You cannot do this.

The exact second that register_netdev() is called, the device can
be brought up asynchronously and the link brought into the up state.

Your netif_carrier_off() call will race with this.

This is why no other (properly functioning) driver does what you're
trying to do here.
