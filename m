From: Florian Westphal <fw@strlen.de>
Subject: Re: updates to syncookies - timestamps not needed any more
 (freebsd)
Date: Fri, 12 Jul 2013 10:41:45 +0200
Message-ID: <20130712084145.GJ27468@breakpoint.cc>
References: <20130708160421.GA9763@order.stressinduktion.org>
 <20130711.165726.2168148122875413191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46275 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757326Ab3GLIlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 04:41:52 -0400
Content-Disposition: inline
In-Reply-To: <20130711.165726.2168148122875413191.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 8 Jul 2013 18:04:21 +0200
> 
> > Interesting patch by Andre Opperann of FreeBSD:
> > <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>
> 
> Interesting work, but outside of the change of hash function I'm not so
> sure.  The whole reason we went to the timestamp field was to eliminate
> the coarse tables.
> 
> I understand that he claims that %99.99 of connections are handled by
> the values he has chosen, but this is still a step backwards in my
> opinion.

The main difference to what linux does is to avoid encoding the 'count'
value (Linux doesn't reseed secret[], and relies on count to detect old
cookies).

Not having the counter frees up space to encode tcp options in the cookie
instead of the timestamp.
