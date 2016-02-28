From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Sun, 28 Feb 2016 18:01:09 +0100
Message-ID: <20160228170109.GA16322@electric-eye.fr.zoreil.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51440 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827AbcB1RBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 12:01:32 -0500
Content-Disposition: inline
In-Reply-To: <1456638957.3676.12.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Galbraith <umgwanakikbuti@gmail.com> :
[...]
> Hrm, relatively new + tasklet woes rings a bell.  Ah, that..
> 
> <quote>
> What's worse is that at the point where this code was written it was
> already well known that tasklets are a steaming pile of crap and
> should die.
> </quote>
> 
> Source thereof https://lwn.net/Articles/588457/

tasklets are ingrained in the dmaengine API (see Documentation/dmaengine/client.txt
and drivers/dma/virt-dma.h::vchan_cookie_complete).

Moving everything to irq context or handling his own sub-{jiffy/ms} timer
while losing async dma doesn't exactly smell like roses either. :o(

-- 
Ueimor
