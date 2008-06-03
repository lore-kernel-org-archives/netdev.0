From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 2/5] sky2: don't warn if page allocation fails
Date: Tue, 3 Jun 2008 16:16:32 +1000
Message-ID: <200806031616.33251.nickpiggin@yahoo.com.au>
References: <20080515000412.984337700@vyatta.com> <48354398.9070307@pobox.com> <20080527114723.4b2b94f9@speedy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754158AbYFCGQ6@vger.kernel.org>
In-Reply-To: <20080527114723.4b2b94f9@speedy>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 May 2008 04:47, Stephen Hemminger wrote:
> On Thu, 22 May 2008 05:57:44 -0400
>
> Jeff Garzik <jgarzik@pobox.com> wrote:
> > >  	for (i = 0; i < sky2->rx_nfrags; i++) {
> > > -		struct page *page = alloc_page(GFP_ATOMIC);
> > > +		struct page *page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
> > >
> > >  		if (!page)
> > >  			goto free_partial;
> >
> > IMO it's inappropriate to add these warnings to net drivers that
> > properly check all return values.
> >
> > This approach is too maintenance intensive, and winds up fixing the same
> > problem over and over again -- a hint that the fix is in the wrong place.
> >
> > 	Jeff
>
> So the __GFP_NOWARN should go away and get replaced by GFP_WARN?

We actually still want to see the messages, regardless of what is causing
them, because they can indicate problems in the VM.

The best way is not to add __GFP_NOWARN at all, and just improve the
throttling/thresholding/reporting of the page allocation failure warnings.
