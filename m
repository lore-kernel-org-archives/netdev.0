From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Mon, 26 Nov 2007 23:35:42 -0600
Message-ID: <1196141742.9876.49.camel@trinity.ogc.int>
References: <20071122343.446909000@suse.de>
	 <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com>
	 <200711271549.37670.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:33632 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713AbXK0GDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 01:03:25 -0500
In-Reply-To: <200711271549.37670.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-11-27 at 15:49 +1100, Rusty Russell wrote:
> On Monday 26 November 2007 17:15:44 Roland Dreier wrote:
> >  > Except C doesn't have namespaces and this mechanism doesn't create them.
> >  >  So this is just complete and utter makework; as I said before, noone's
> >  > going to confuse all those udp_* functions if they're not in the udp
> >  > namespace.
> >
> > I don't understand why you're so opposed to organizing the kernel's
> > exported symbols in a more self-documenting way.
> 
> No, I was the one who moved exports near their declarations.  That's 
> organised.  I just don't see how this new "organization" will help: oh good, 
> I won't accidentally use the udp functions any more?!?
> 
> > It seems pretty   
> > clear to me that having a mechanism that requires modules to make
> > explicit which (semi-)internal APIs makes reviewing easier
> 
> Perhaps you've got lots of patches were people are using internal APIs they 
> shouldn't?
> 

Maybe the issue is "who can tell" since what is external and what is
internal is not explicitly defined?

> > , makes it 
> > easier to communicate "please don't use that API" to module authors,
> 
> Well, introduce an EXPORT_SYMBOL_INTERNAL().  It's a lot less code.  But you'd 
> still need to show that people are having trouble knowing what APIs to use.

> > and takes at least a small step towards bringing the kernel's exported
> > API under control.
> 
> There is no "exported API" to bring under control.  

Hmm...apparently, there are those that are struggling...

> There are symbols we 
> expose for the kernel's own use which can be used by external modules at 
> their own risk.  
> 
> > What's the real downside? 
> 
> No.  That's the wrong question.  What's the real upside?

Explicitly documenting what comprises the kernel API (external,
supported) and what comprises the kernel implementation (internal, not
supported).

> 
> Let's not put code in the core because "it doesn't seem to hurt".
> 

agreed.

> I'm sure you think there's a real problem, but I'm still waiting for someone 
> to *show* it to me.  Then we can look at solutions.

I think the benefits should include:

- forcing developers to identify their exports as part of the
implementation or as part of the kernel API

- making it easier for reviewers to identify when developers are adding
to the kernel API and thereby focusing the appropriate level of review
to the new function

- making it obvious to developers when they are binding their
implementation to a particular kernel release



> Rusty.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

