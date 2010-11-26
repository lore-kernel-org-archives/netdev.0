From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment
 bsockets and num_owners
Date: Fri, 26 Nov 2010 14:07:26 +0300
Message-ID: <20101126110726.GA5648@ioremap.net>
References: <751926.73238.qm@web53707.mail.re2.yahoo.com>
 <1290768477.2855.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nagendra Tomar <tomer_iisc@yahoo.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:43847 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754690Ab0KZLRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 06:17:22 -0500
Content-Disposition: inline
In-Reply-To: <1290768477.2855.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Nov 26, 2010 at 11:47:57AM +0100, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> > ok, so I printed hashinfo->bsockets and tb->num_owners inside
> > __inet_put_port() and I could see both of them to be -ve. All we need
> > to do is establish and terminate a connection. I used netcat for that.
> > 
> > The only place 'bsockets' and 'num_owners' are used is
> > inet_csk_get_port() and the only effect that they might have is on the
> > choice of the port to be used for binding. 
> > 'bsockets' is used as a hint to stop searching for a free port (and
> > instead share an already used port) when we know that all the ports
> > could be used up.
> > 'num_owners' is used to find the port which is least shared (to
> > balance the 'owners' list) in case we need to share a port.
> > 
> > Since both of these are used as optimizations (in the bind path), they
> > do not affect correctness and hence the code works even with these
> > values not being updated correctly.
> 
> Hmm, thanks for clarification.
> 
> bsockets / mnum_owners iscount is indeed an 'optimization' problem.
> 
> Problem is your patch is not applicable to current tree.
> 
> In order to submit it to stable team, you should first post a patch for
> next/current kernel (net-next-2.6 tree).
> 
> David will decide if its net-2.6 material or not.
> 
> You could add in your changelog the problem comes from commit 
> a9d8f9110d7e953c (inet: Allowing more than 64k connections and heavily
> optimize bind(0)), included in 2.6.30, to ease stable team work.

Frankly I did not find how those optimizations made a bug as well as
what is this bug about from given description, but I'm glad it is resolved now :)

-- 
	Evgeniy Polyakov
