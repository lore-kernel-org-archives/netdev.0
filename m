From: David Miller <davem@davemloft.net>
Subject: Re: DECnet routing rule resolution
Date: Thu, 29 Mar 2007 11:43:06 -0700 (PDT)
Message-ID: <20070329.114306.112621613.davem@davemloft.net>
References: <1175185450.1636.124.camel@quoit.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, pcaulfie@redhat.com
To: swhiteho@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934322AbXC2SnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 14:43:08 -0400
In-Reply-To: <1175185450.1636.124.camel@quoit.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Thu, 29 Mar 2007 17:24:10 +0100

> One of the effects of the recent tidy up of the DECnet routing rules
> code is that we are no longer able to see the difference between reading
> a rule of type FR_ACT_UNREACHABLE returning -ENETUNREACH and simply
> running out of rules to look at, which also returns the same thing.
> 
> The DECnet code used to return -ESRCH if it ran out of rules in which
> case the test in dn_route.c (which resulted in DECnet falling back to
> endnode routing in the -ESRCH case) no longer works.
> 
> So there seems to be several options to try and solve this: one is to
> change the error return for running out of rules in
> fib_rules.c:fib_rules_lookup() to something else (but then that has a
> knock on effect in the ipv4 code). Another is to add the "not found"
> error return as a parameter in the struct fib_rules_ops so that both
> protocols can have their preferred error return. Both solutions seem a
> bit messy, so I thought I'd ask for some guidance on this before writing
> a patch,

I think we should be able to return -ESRCH (a more sensible error
value if you ask me) across the board.

Thomas what do you think?
