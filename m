From: Thomas Graf <tgraf@suug.ch>
Subject: Re: DECnet routing rule resolution
Date: Thu, 29 Mar 2007 22:01:52 +0200
Message-ID: <20070329200151.GQ521@postel.suug.ch>
References: <1175185450.1636.124.camel@quoit.chygwyn.com> <20070329.114306.112621613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: swhiteho@redhat.com, netdev@vger.kernel.org, pcaulfie@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44583 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030624AbXC2UBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 16:01:31 -0400
Content-Disposition: inline
In-Reply-To: <20070329.114306.112621613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2007-03-29 11:43
> From: Steven Whitehouse <swhiteho@redhat.com>
> Date: Thu, 29 Mar 2007 17:24:10 +0100
> 
> > One of the effects of the recent tidy up of the DECnet routing rules
> > code is that we are no longer able to see the difference between reading
> > a rule of type FR_ACT_UNREACHABLE returning -ENETUNREACH and simply
> > running out of rules to look at, which also returns the same thing.
> > 
> > The DECnet code used to return -ESRCH if it ran out of rules in which
> > case the test in dn_route.c (which resulted in DECnet falling back to
> > endnode routing in the -ESRCH case) no longer works.
> > 
> > So there seems to be several options to try and solve this: one is to
> > change the error return for running out of rules in
> > fib_rules.c:fib_rules_lookup() to something else (but then that has a
> > knock on effect in the ipv4 code). Another is to add the "not found"
> > error return as a parameter in the struct fib_rules_ops so that both
> > protocols can have their preferred error return. Both solutions seem a
> > bit messy, so I thought I'd ask for some guidance on this before writing
> > a patch,
> 
> I think we should be able to return -ESRCH (a more sensible error
> value if you ask me) across the board.
> 
> Thomas what do you think?

I agree.
