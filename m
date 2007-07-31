From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Mon, 30 Jul 2007 17:25:45 -0700 (PDT)
Message-ID: <20070730.172545.59831449.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC002AAB9F8@nt-irva-0751.brcm.ad.broadcom.com>
	<20070726.001516.48528000.davem@davemloft.net>
	<1185485889.7922.83.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55316
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760830AbXGaAZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:25:46 -0400
In-Reply-To: <1185485889.7922.83.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 26 Jul 2007 14:38:09 -0700

> If the driver wants a simple solution, it can do what you did in the
> patch:  wrap the tx cleanup code with netif_tx_lock() and
> netif_tx_unlock().
> 
> If a NAPI driver wants to be more clever, it can do something such as
> this in tg3's poll_controller:
> 
> if (netif_rx_schedule_prep(dev, &tp->napi)) {
> 	tg3_tx(tp);
> 	netif_poll_enable(tp->napi);
> }

Thanks Michael, that's a good suggestion and would work.

In thinking about this some more over the weekend I've decided
that my plan to rip out RX support from netpoll is a bit too
ambitious.

Therefore, for the time being, I'm going to add a special driver
function for netpoll that will allow it to ask the driver to invoke
->poll() over all the NAPI structs assosciated with the netdev.
