From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 11:51:27 -0700
Message-ID: <20080724115127.6cfbb616.akpm@linux-foundation.org>
References: <20080724060448.GA10203@elte.hu>
	<E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
	<20080724.022259.113079007.davem@davemloft.net>
	<20080724093411.GA12001@elte.hu>
	<20080724115625.GA23994@elte.hu>
	<20080724115957.GA25701@elte.hu>
	<48886FA6.6050908@trash.net>
	<84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com>
	<48887A71.5010209@trash.net>
	<1216905812.5897.6.camel@penberg-laptop>
	<48888434.3030207@trash.net>
	<1216906476.12021.4.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52139 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752543AbYGXSyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 14:54:00 -0400
In-Reply-To: <1216906476.12021.4.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008 16:34:36 +0300 Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> > >> Your patch introduced a use-after-free and double-free.
> > >> krealloc() frees the old pointer, but it is still used
> > >> for the ->move operations, then freed again.
> > >>
> > >> To fix this I think we need a __krealloc() that doesn't
> > >> free the old memory, especially since it must not be
> > >> freed immediately because it may still be used in a RCU
> > >> read side (see the last part in the patch attached to
> > >> this mail (based on a kernel without your patch)).
> > > 
> > > Agreed. Something like this, perhaps?
> > > 
> > > [PATCH] netfilter: fix double-free and use-after free
> > > 
> > > As suggested by Patrick McHardy, introduce a __krealloc() that doesn't
> > > free the original buffer to fix a double-free and use-after-free bug
> > > introduced by me in netfilter that uses RCU.
> > > 
> > > Reported-by: Patrick McHardy <kaber@trash.net>
> > > Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> > 
> > Looks good to me, thanks.
> 
> Ingo, can you please test this? Andrew, I'm at OLS so can you pick up
> the patch in your tree?

Sure.  Or Patrick can do so and it can be merged via the net tree.

Ingo, did this patch actually fix something over there?
