From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Minimizing TCP latency
Date: Mon, 29 Mar 2010 08:40:33 -0400
Message-ID: <20100329124033.GB22733@hmsreliant.think-freely.org>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
 <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hoyt <benhoyt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49639 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab0C2Mkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 08:40:37 -0400
Content-Disposition: inline
In-Reply-To: <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 04:24:04PM +1300, Ben Hoyt wrote:
> > I'm happy to receive some pointers via this list [...]
> 
> Sorry, I should also have posted more about what I've done in terms of
> reducing latency so far:
> 
> * We've already got TCP_NODELAY activated.
> 
> * We've also turned off interrupt coalescing on the network card (for
> example, see http://www.29west.com/docs/THPM/latency-interrupt-coalescing.html).
> 
Careful, this might wind up hurting you.  It decreases latency from the card,
but might result in flooding one or more cores with additional interrupts that
delay processing of packets further down the line.

> * We've modified our process's CPU affinity so it runs on a core by
> itself, reducing interrupt-handling latency slightly further.
> 
Whats your interrupt affinity look like?

> * Our code is written in C, and we've tried to keep it as close to the
> kernel's socket calls as possible.
> 
> So we're currently looking further into ways to reduce latency, which
> currently looks like it'll mean digging deeper into the kernel's
> networking options and innards.
> 
> FYI, we're using RHE release 4 and kernel version 2.6.9 on x86_64 machines.
> 
> -Ben
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
