From: Jesper Derehag <jderehag@hotmail.com>
Subject: RE: [PATCH 1/1] connector: Added coredumping event to the process
 connector
Date: Wed, 20 Mar 2013 06:53:45 +0000
Message-ID: <DUB002-W81D7BE8CAFEDCD21E3837CDDEA0@phx.gbl>
References: <DUB002-W14207698E8638F6DEB6F4A7DDEE0@phx.gbl>
 <DUB002-W153FA7D4CB9EB6CFF1689B3DDE90@phx.gbl>,<20130319170932.GB24909@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zbr@ioremap.net" <zbr@ioremap.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s18.dub0.hotmail.com ([157.55.2.93]:22773 "EHLO
	dub0-omc4-s18.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751422Ab3CTGxq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 02:53:46 -0400
In-Reply-To: <20130319170932.GB24909@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----------------------------------------
> Date: Tue, 19 Mar 2013 18:09:32 +0100
> From: hannes@stressinduktion.org
> To: jderehag@hotmail.com
> CC: netdev@vger.kernel.org; zbr@ioremap.net
> Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
>
> On Tue, Mar 19, 2013 at 07:32:10AM +0000, Jesper Derehag wrote:
> > > From: jderehag@hotmail.com
> > > To: netdev@vger.kernel.org
> > > Subject: RE: [PATCH 1/1] connector: Added coredumping event to the process connector
> > > Date: Sat, 16 Mar 2013 19:08:03 +0000
> > >
> > > ----------------------------------------
> > > > Date: Sat, 16 Mar 2013 19:40:36 +0100
> > > > From: hannes@stressinduktion.org
> > > > To: jderehag@hotmail.com
> > > > CC: zbr@ioremap.net; netdev@vger.kernel.org
> > > > Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
> > > >
> > > > On Sat, Mar 16, 2013 at 05:57:20PM +0000, Jesper Derehag wrote:
> > > > >
> > > > >
> > > > > > Date: Sat, 16 Mar 2013 18:03:48 +0100
> > > > > > From: hannes@stressinduktion.org
> > > > > > To: jderehag@hotmail.com
> > > > > > CC: zbr@ioremap.net; netdev@vger.kernel.org
> > > > > > Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
> > > > > >
> > > > > > On Sat, Mar 16, 2013 at 11:50:50AM +0100, Jesper Derehag wrote:
> > > > > > > + ev->event_data.exit.exit_code = task->exit_code;
> > > > > > > + ev->event_data.exit.exit_signal = task->exit_signal;
> > > > > >
> > > > > > Do these already contain meaningful values?
> > > > > >
> > > > >
> > > > > I have to admit that they dont.And you are correct, I should add a new event struct specific for the coredump event instead of piggybacking on the exit struct.Will re-submit a patch..
> > > >
> > > > Hm, I am still unsure if such a patch is needed. Couldn't you test for
> > > > coredump by inspecting exit_code on PROC_EVENT_EXIT?
> > >
> > > *** resubmitted message due to it got dropped by vger.kernel.org ***
> > >
> > > Well, what this patch adds I think is more a question of timing.
> > > As an example, say you want to quickly detect process failures. In that case if we would only have the EXIT event, that would mean that we get notified after the dump is done, which could take minutes depending on how large the dump is.
> > > If we instead watch for both EXIT & COREDUMP events, it would mean that we would quickly catch any failing process, regardless of if its actually starting to coredump or if its exited for some other reason.
> >
> >
> > Any other comments on this before I send a v2 patch with the exit vs the coredump event struct change?
>
> I would say just go on and submit the patch. Perhaps you can Cc someone
> looking after the change in signal.c (maybe lkml). I just checked that
> you don't hold any spinlocks while doing the netlink send.
>

Great.
Just submitted the v2 patch (and cc:ing lkml), thanks for your help! Much appreciated.. 		 	   		  