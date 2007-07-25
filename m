From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 21:29:51 -0700 (PDT)
Message-ID: <20070724.212951.70218044.davem@davemloft.net>
References: <1185326149.1803.421.camel@localhost.localdomain>
	<20070724.184759.111203672.davem@davemloft.net>
	<1185330794.1803.452.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750799AbXGYE3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 00:29:52 -0400
In-Reply-To: <1185330794.1803.452.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 25 Jul 2007 12:33:14 +1000

> Maybe by adding YA state bit?  Hold on, this might get ugly...
> 
> Say netif_rx_schedule_prep() sets the MORE_TODO bit (atomically instead
> of setting __LINK_STATE_RX_SCHED) if it's going to fail, and
> netif_rx_complete() returns 0 if it was set, or 1 if it's OK.  Now
> callers do:
> 
> 	reenable_interrupts();
>         if (rx_pending() || !netif_rx_complete(netdev, napi))
>                 disable_interrupts();

This is an interesting idea, and would work, but the extra atomics
for something that 2 or 3 drivers actually need.... unless I
misunderstand your suggestion?
