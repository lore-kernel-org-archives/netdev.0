From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ll_temac: Fix poll implementation
Date: Thu, 19 Aug 2010 00:48:45 -0700 (PDT)
Message-ID: <20100819.004845.148553935.davem@davemloft.net>
References: <1282127194-4185-1-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: glikely@secretlab.ca, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750794Ab0HSHs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:48:26 -0400
In-Reply-To: <1282127194-4185-1-git-send-email-monstr@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <monstr@monstr.eu>
Date: Wed, 18 Aug 2010 12:26:34 +0200

> Functions ll_temac_rx_irq and ll_temac_tx_irq
> have pointer to net_device as second parameter not
> pointer to temac_local.
> 
> Signed-off-by: Michal Simek <monstr@monstr.eu>

Applied, thanks a lot.

I can't count how many times this kind of error has been
introduced.  It's of cource because the handle passed to
IRQ handlers is an opaque void pointer, so if the underlying
type gets changed there is absolutely no type checking done
against by-hand calls of the IRQ handler.

Rusty Russell was, if I remember correctly, doing some work
to correct this such that IRQ handlers could in fact have
some proper typing in their handlers.  Or maybe that was for
timer handlers?

Anyways that kind of thing would help here.

Rusty?
