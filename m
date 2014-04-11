From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Thu, 10 Apr 2014 19:09:30 -0700
Message-ID: <1397182170.16584.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140407142334.GA28814@gondor.apana.org.au>
	 <53442868.3090701@candelatech.com>
	 <20140408172349.GA7147@gondor.apana.org.au>
	 <20140410.214023.849284639345029049.davem@davemloft.net>
	 <20140411015906.GB31251@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:61329 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621AbaDKCJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 22:09:33 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so4732109pbb.36
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 19:09:32 -0700 (PDT)
In-Reply-To: <20140411015906.GB31251@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-04-11 at 09:59 +0800, Herbert Xu wrote:
> On Thu, Apr 10, 2014 at 09:40:23PM -0400, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Wed, 9 Apr 2014 01:23:49 +0800
> > 
> > > On Tue, Apr 08, 2014 at 09:48:40AM -0700, Ben Greear wrote:
> > >> 
> > >> At least for ARPs, maybe we could inspect the packet and only
> > >> deliver to interfaces configured with the MAC that is being
> > >> ARPed for (or ones that are in promisc)?
> > > 
> > > Yes this would definitely be a great optimisation.
> > 
> > Yes and you can use the direct rather than the workqueue path.
> 
> This would be a worthy optimisation for bridge.c too.  In fact,
> I wonder if it would be possible to share some of the broadcast/
> multicast logic between macvlan and bridge.

But many ARP messages are broadcasted, particularly when you restart
an hypervisor with thousand of macvlan. This is the moment we have
this horrible quadratic behavior in macvlan.

I do not understand the idea...

ARP filter would require to inspect the queried IPv4 address, and
macvlan do not currently have a list of IPv4 addresses per port.
