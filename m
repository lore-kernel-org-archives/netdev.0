From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 15:11:20 -0700
Message-ID: <20080919151120.6f397192@infradead.org>
References: <20080918.193815.175549834.davem@davemloft.net>
	<41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com>
	<20080919181840.GE30956@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58052 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbYISWLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 18:11:22 -0400
In-Reply-To: <20080919181840.GE30956@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Sep 2008 12:18:41 -0600
Matthew Wilcox <matthew@wil.cx> wrote:
> 
> Another idea I've been thinking about is a flag to tell irqbalance to
> leave stuff alone, and we just set stuff up right the first time.

that's not a good answer. There are reasons for moving interrupts that
are a sysadmin choice (like power management policy that if the system
is seriously idle, that all interrupts go to one of the sockets so that
the others can stay in low power mode). Putting the policy in the kernel
to prohibit such admin choices sounds like a bad idea to me.

There are better ways to do what you want, for example by exposing a
"preferred cpu" somewhere so that irqbalance will place it there
"unless <...>". That is, if such kernel policy binding is right in the
first place

> In a storage / NUMA configuration we really want to set up one queue
> per cpu / package / node (depending on resource constraints) and know
> that the interrupt is going to come back to the same cpu / package /
> node. We definitely don't want irqbalanced moving the interrupt
> around.

irqbalance is NUMA aware and places a penalty on placing an interrupt
"wrongly". We can argue on how strong this penalty should be, but
thinking that irqbalance doesn't use the numa info the kernel exposes
is incorrect.



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
