From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC net] tcp: metrics: Avoid duplicate entries with the same
 destination-IP
Date: Thu, 16 Jan 2014 00:21:33 +0100
Message-ID: <20140115232133.GA4957@cpaasch-mac>
References: <1389626736-3143-1-git-send-email-christoph.paasch@uclouvain.be>
 <1389631669.31367.221.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140115.121856.712581760900022040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:58858 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbaAOXVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:21:41 -0500
Content-Disposition: inline
In-Reply-To: <20140115.121856.712581760900022040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/01/14 - 12:18:56, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 13 Jan 2014 08:47:49 -0800
> 
> > On Mon, 2014-01-13 at 16:25 +0100, Christoph Paasch wrote:
> > 
> >> Another solution might be to leave tcp_get_metrics() as it is, and in
> >> tcpm_new do another call to __tcp_get_metrics() while holding the
> >> spin-lock. We would then check __tcp_get_metrics twice for new entries
> >> but we won't hold the spin-lock needlessly anymore.
> > 
> > This is the only solution if you want to fix this.
> > Cost of lookup are the cache line misses.
> > Avoiding the spinlock is a must.
> > 
> > The second 'lookup' is basically free, as the first one have populated
> > cpu caches.
> 
> Indeed, taking the lock in tcp_get_metrics() is to be avoided at all
> costs.

Yes, I will send the updated patch tomorrow. Didn't yet had the time to send
it.


Christoph
