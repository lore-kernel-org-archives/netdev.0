From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 2/5] sky2: don't warn if page allocation fails
Date: Tue, 27 May 2008 11:47:23 -0700
Message-ID: <20080527114723.4b2b94f9@speedy>
References: <20080515000412.984337700@vyatta.com>
	<20080515000432.989061538@vyatta.com>
	<48354398.9070307@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48731 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757115AbYE0SrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 14:47:24 -0400
In-Reply-To: <48354398.9070307@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 May 2008 05:57:44 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> >  
> >  	for (i = 0; i < sky2->rx_nfrags; i++) {
> > -		struct page *page = alloc_page(GFP_ATOMIC);
> > +		struct page *page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
> >  
> >  		if (!page)
> >  			goto free_partial;
> 
> 
> IMO it's inappropriate to add these warnings to net drivers that 
> properly check all return values.
> 
> This approach is too maintenance intensive, and winds up fixing the same 
> problem over and over again -- a hint that the fix is in the wrong place.
> 
> 	Jeff
> 
> 

So the __GFP_NOWARN should go away and get replaced by GFP_WARN?
