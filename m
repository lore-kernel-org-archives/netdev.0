From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Subject: Re: netif_poll_enable() & barrier
Date: Fri, 29 Dec 2006 16:45:35 +1100
Message-ID: <1167371135.23340.99.camel@localhost.localdomain>
References: <1166586252.19254.118.camel@localhost.localdomain>
	 <20061228.210956.85409699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:65430 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbWL2FqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 00:46:10 -0500
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kBT5xKWt064758
	for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 16:59:20 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBT5nPYb194642
	for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 16:49:35 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBT5jkYE031496
	for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 16:45:46 +1100
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061228.210956.85409699.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-28 at 21:09 -0800, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@au1.ibm.com>
> Date: Wed, 20 Dec 2006 14:44:12 +1100
> 
> > I stumbled accross what might be a bug on out of order architecture:
> > 
> > netif_poll_enable() only does a clear_bit(). However,
> > netif_poll_disable/enable pairs are often used as simili-spinlocks.
> > 
> > (netif_poll_enable() has pretty much spin_lock semantics except that it
> > schedules instead of looping).
> > 
> > Thus, shouldn't netif_poll_disable() do an smp_wmb(); before clearing
> > the bit to make sure that any stores done within the poll-disabled
> > section are properly visible to the rest of the system before clearing
> > the bit ?
> 
> Although I couldn't find a problematic case with any current
> in-tree drivers, it's better to be safe than sorry :-)
> 
> So I'll add a smp_mb__before_clear_bit() to netif_poll_enable() :)

Heh, thanks ! :-)

I haven't seen any problematic case neither, though if there was one, it
would result in weird problems very hard to track down, so as you said,
better safe than sorry (unless you see a flaw in my reasoning).

Cheers,

Oh, and happy new year too ! :-)

Ben.

