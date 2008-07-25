From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Fri, 25 Jul 2008 13:41:56 +0300
Message-ID: <1216982516.5896.0.camel@penberg-laptop>
References: <20080724060448.GA10203@elte.hu>
	 <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
	 <20080724.022259.113079007.davem@davemloft.net>
	 <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>
	 <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net>
	 <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com>
	 <48887A71.5010209@trash.net> <1216905812.5897.6.camel@penberg-laptop>
	 <48888434.3030207@trash.net> <1216906476.12021.4.camel@penberg-laptop>
	 <20080724115127.6cfbb616.akpm@linux-foundation.org>
	 <1216925744.12392.1.camel@penberg-laptop>  <4889887B.1080206@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>, vegard.nossum@gmail.com
To: Dieter Ries <clip2@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51984 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbYGYKmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 06:42:02 -0400
In-Reply-To: <4889887B.1080206@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-25 at 10:02 +0200, Dieter Ries wrote:
> Pekka Enberg schrieb:
> > On Thu, 2008-07-24 at 11:51 -0700, Andrew Morton wrote:
> >> On Thu, 24 Jul 2008 16:34:36 +0300 Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> >>
> >>>>>> Your patch introduced a use-after-free and double-free.
> >>>>>> krealloc() frees the old pointer, but it is still used
> >>>>>> for the ->move operations, then freed again.
> >>>>>>
> >>>>>> To fix this I think we need a __krealloc() that doesn't
> >>>>>> free the old memory, especially since it must not be
> >>>>>> freed immediately because it may still be used in a RCU
> >>>>>> read side (see the last part in the patch attached to
> >>>>>> this mail (based on a kernel without your patch)).
> >>>>> Agreed. Something like this, perhaps?
> >>>>>
> >>>>> [PATCH] netfilter: fix double-free and use-after free
> >>>>>
> >>>>> As suggested by Patrick McHardy, introduce a __krealloc() that doesn't
> >>>>> free the original buffer to fix a double-free and use-after-free bug
> >>>>> introduced by me in netfilter that uses RCU.
> >>>>>
> >>>>> Reported-by: Patrick McHardy <kaber@trash.net>
> >>>>> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> >>>> Looks good to me, thanks.
> >>> Ingo, can you please test this? Andrew, I'm at OLS so can you pick up
> >>> the patch in your tree?
> >> Sure.  Or Patrick can do so and it can be merged via the net tree.
> >>
> >> Ingo, did this patch actually fix something over there?
> > 
> > Apparently it didn't but it did fix Dieter's problem:
> > 
> > http://lkml.org/lkml/2008/7/24/337
> > 
> > Dieter, can we add a Tested-by tag from you to this patch?
> > 
> 
> Yes, it definitely fixed my issue and I have not encountered 
>                             further problems with the patch. The machine 
> is running fine with it.
> 
> Do I have to explicitly add my
> Tested-by: Dieter Ries <clip2@gmx.de>
> tag somewhere (if yes, where?) or is this enough for you?

No, that's fine. The people who are merging the patch can pick it up.
Thanks a lot for your help!

		Pekka

