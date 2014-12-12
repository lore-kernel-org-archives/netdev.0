From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 00/11] net: remove disable_irq() from
 ->ndo_poll_controller
Date: Thu, 11 Dec 2014 21:14:02 -0500 (EST)
Message-ID: <20141211.211402.2185620924873688973.davem@davemloft.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
	<20141209.214433.7463087833083181.davem@davemloft.net>
	<20141211214537.GA4159@kria>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peterz@infradead.org, tglx@linutronix.de
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758620AbaLLCOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 21:14:03 -0500
In-Reply-To: <20141211214537.GA4159@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu, 11 Dec 2014 22:45:37 +0100

> Introduce disable_irq_nosleep() that returns true if it successfully
> synchronized against all handlers (there was no threaded handler
> running), false if it left some threads running.  And in
> ->ndo_poll_controller, only call the interrupt handler if
> synchronization was successful.
> 
> Both users of the poll controllers retry their action (alloc/xmit an
> skb) several times, with calls to the device's poll controller between
> attempts.  And hopefully, if the first attempt fails, we will still
> manage to get through?

This looks more palatable to me.
