From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
Date: Tue, 19 Mar 2013 18:09:32 +0100
Message-ID: <20130319170932.GB24909@order.stressinduktion.org>
References: <DUB002-W14207698E8638F6DEB6F4A7DDEE0@phx.gbl> <DUB002-W153FA7D4CB9EB6CFF1689B3DDE90@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zbr@ioremap.net" <zbr@ioremap.net>
To: Jesper Derehag <jderehag@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44861 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab3CSRJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:09:33 -0400
Content-Disposition: inline
In-Reply-To: <DUB002-W153FA7D4CB9EB6CFF1689B3DDE90@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 07:32:10AM +0000, Jesper Derehag wrote:
> > From: jderehag@hotmail.com
> > To: netdev@vger.kernel.org
> > Subject: RE: [PATCH 1/1] connector: Added coredumping event to the process connector
> > Date: Sat, 16 Mar 2013 19:08:03 +0000
> > 
> > ----------------------------------------
> > > Date: Sat, 16 Mar 2013 19:40:36 +0100
> > > From: hannes@stressinduktion.org
> > > To: jderehag@hotmail.com
> > > CC: zbr@ioremap.net; netdev@vger.kernel.org
> > > Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
> > >
> > > On Sat, Mar 16, 2013 at 05:57:20PM +0000, Jesper Derehag wrote:
> > > >
> > > >
> > > > > Date: Sat, 16 Mar 2013 18:03:48 +0100
> > > > > From: hannes@stressinduktion.org
> > > > > To: jderehag@hotmail.com
> > > > > CC: zbr@ioremap.net; netdev@vger.kernel.org
> > > > > Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
> > > > >
> > > > > On Sat, Mar 16, 2013 at 11:50:50AM +0100, Jesper Derehag wrote:
> > > > > > + ev->event_data.exit.exit_code = task->exit_code;
> > > > > > + ev->event_data.exit.exit_signal = task->exit_signal;
> > > > >
> > > > > Do these already contain meaningful values?
> > > > >
> > > >
> > > > I have to admit that they dont.And you are correct, I should add a new event struct specific for the coredump event instead of piggybacking on the exit struct.Will re-submit a patch..
> > >
> > > Hm, I am still unsure if such a patch is needed. Couldn't you test for
> > > coredump by inspecting exit_code on PROC_EVENT_EXIT?
> > 
> > *** resubmitted message due to it got dropped by vger.kernel.org ***
> > 
> >  Well, what this patch adds I think is more a question of timing. 
> >  As an example, say you want to quickly detect process failures. In that case if we would only have the EXIT event, that would mean that we get notified after the dump is done, which could take minutes depending on how large the dump is. 
> > If we instead watch for both EXIT & COREDUMP events, it would mean that we would quickly catch any failing process, regardless of if its actually starting to coredump or if its exited for some other reason. 		 	   		  
> 
> 
> Any other comments on this before I send a v2 patch with the exit vs the coredump event struct change?

I would say just go on and submit the patch. Perhaps you can Cc someone
looking after the change in signal.c (maybe lkml). I just checked that
you don't hold any spinlocks while doing the netlink send.
