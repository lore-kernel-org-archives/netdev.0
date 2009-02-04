From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 09:54:32 +0100
Message-ID: <20090204085432.GA21638@1wt.eu>
References: <20090203121209.GA9154@gondor.apana.org.au> <20090203121836.GA23300@ioremap.net> <20090203122535.GB8633@1wt.eu> <20090203.164734.76871204.davem@davemloft.net> <20090204061947.GD20673@1wt.eu> <20090204081201.GB10445@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	jarkao2@gmail.com, dada1@cosmosbay.com, ben@zeus.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2008 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbZBDIzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 03:55:05 -0500
Content-Disposition: inline
In-Reply-To: <20090204081201.GB10445@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 11:12:01AM +0300, Evgeniy Polyakov wrote:
> On Wed, Feb 04, 2009 at 07:19:47AM +0100, Willy Tarreau (w@1wt.eu) wrote:
> > Yes myri10ge for the optimal 4080, but with e1000 too (though I don't
> > remember the exact optimal value, I think it was slightly lower).
> 
> Very likely it is related to the allocator - the same allocation
> overhead to get a page, but 2.5 times bigger frame.
> 
> > For the myri10ge, could this be caused by the cache footprint then ?
> > I can also retry with various values between 4 and 9k, including
> > values close to 8k. Maybe the fact that 4k is better than 9 is
> > because we get better filling of all pages ?
> > 
> > I also remember having used a 7 kB MTU on e1000 and dl2k in the past.
> > BTW, 7k MTU on my NFS server which uses e1000 definitely stopped the
> > allocation failures which were polluting the logs, so it's been running
> > with that setting for years now.
> 
> Recent e1000 (e1000e) uses fragments, so it does not suffer from the
> high-order allocation failures.

My server is running 2.4 :-), but I observed the same issues with older
2.6 as well. I can certainly imagine that things have changed a lot since,
but the initial point remains : jumbo frames are expensive to deal with,
and with recent NICs and drivers, we might get close performance for
little additional cost. After all, initial justification for jumbo frames
was the devastating interrupt rate and all NICs coalesce interrupts now.

So if we can optimize all the infrastructure for extremely fast
processing of standard frames (1500) and still support jumbo frames
in a suboptimal mode, I think it could be a very good trade-off.

Regards,
willy

