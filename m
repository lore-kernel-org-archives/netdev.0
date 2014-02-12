From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] ipv4: arp: process only if ipv4 address configured
Date: Wed, 12 Feb 2014 23:01:43 +0100
Message-ID: <20140212220143.GD25153@breakpoint.cc>
References: <1392226067-21736-1-git-send-email-fw@strlen.de>
 <1392229587.1752.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40847 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753563AbaBLWBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:01:44 -0500
Content-Disposition: inline
In-Reply-To: <1392229587.1752.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-02-12 at 18:27 +0100, Florian Westphal wrote:
> > 8030f54499925d073a88c09f ([IPV4] devinet: Register inetdev earlier.)
> > changed arp behaviour (2.6.22 onwards).
> > 
> > Before this, inetdev_init() was called only when the first address was
> > added to the interface, i.e. arp_process always dropped incoming arp
> > packets as __in_dev_get_rcu() returned NULL when no IP address was set
> > on the interface.
> > 
> > With >= 2.6.22 we now process arp packets even if no address is assigned.
> > It can cause issues if the machine has several interfaces in the same
> > segment; requests receive answers from multiple macs.
> 
> What about arp_filter value/meaning ?

Sure, arp_filter=1 avoids this.

If you mean "we don't care, its been like this for years and if you
don't want it then set arp_filter=1" -- fine with me.

Sorry if this wasn't clear -- its more about the change in behaviour
and if we should care.
