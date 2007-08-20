From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: enable poll() before registering interrupts
Date: Mon, 20 Aug 2007 17:29:45 -0500
Message-ID: <20070820222945.GJ4261@austin.ibm.com>
References: <200707120119.12589.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Christian Krafft <krafft@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:46126 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953AbXHTW3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 18:29:47 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7KMTlO8022145
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 18:29:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7KMTk85397572
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 18:29:46 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7KMTkui008796
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 18:29:46 -0400
Content-Disposition: inline
In-Reply-To: <200707120119.12589.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 01:19:11AM +0200, Arnd Bergmann wrote:
> We must not call netif_poll_enable after enabling interrupts,
> because an interrupt might come in and set the __LINK_STATE_RX_SCHED
> bit before we get to clear that bit again. If that happens,
> the next call to the ->poll() function will oops.
> 
> Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>
> ---
> This was found during testing with the fedora kernel,
> with all patches from netdev-2.6.git applied.
> 
> It may not be the right fix, but this is currently the
> only way I can get that kernel to boot.
> 
> One part I don't understand at the moment is that Christian
> Krafft reported the same problem with tg3, but that driver
> has all interrupts disabled at the device while calling
> the request_irq() function, which seems to be the best
> solution for avoiding the bug in the first place.

It apears that this patch does not apply cleanly any more,
and I think that's a good thing! 

An intervening patch changed the init so that the 
hardware interrupts aren't enabled until after the
request_irq, and after the poll_enable().  Thus,
it seems this pach is no longer needed, right?

I'll pursue with Kou Ishizaki, who pointed out that
I'd missed your email.

--linas

