From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Wed, 22 Jun 2016 09:29:39 +0930
Message-ID: <20160621235938.GB13364@marvin.atrad.com.au>
References: <20151122230244.GA12249@electric-eye.fr.zoreil.com>
 <20151130064255.GL5537@marvin.atrad.com.au>
 <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
 <20160518065137.GJ27564@marvin.atrad.com.au>
 <20160601003123.GE3384@marvin.atrad.com.au>
 <20160621032133.GC19735@marvin.atrad.com.au>
 <20160621230957.GA19674@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:52263 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbcFUX7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 19:59:47 -0400
Content-Disposition: inline
In-Reply-To: <20160621230957.GA19674@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 01:09:57AM +0200, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > Is there any chance that this regression can be resolved?  It's been 6
> > months since the last contact was received from the list in relation to this
> > issue.  If the r8169 driver is to remain broken with respect to UDP traffic
> > then we will have no choice but to factor in a change in our standard
> > hardware for future systems.  Unfortunately this also means that dozens of
> > systems in the field cannot be upgraded to recent kernels since doing so
> > will trigger the regression.[1]
> 
> If I understood correctly (2015/11/21) you had a working system with a stock
> 4.2 or 4.3 kernel and the r8169.c from 1e874e041fc7c222cbd85b20c4406070be1f687a
> (i.e. da78dbff2e05630921c551dbbc70a4b7981a8fff "r8169: remove work from irq
> handler." parent) patched with the snippet below, right ?

Thanks for your response.

You are correct: that combination worked just fine.  From the response given
at the time it seemed that further follow-up work was on the way, so I was
puzzled when this didn't eventuate.

> If so, while not perfect, it should at least mitigate the "can't upgrade
> kernel" part.

Yes, it does do that.  I was under the impression that mainline could be
subsequently patched to fix the regression based on understandings gained
from the outcome of this workaround, but it seems that hasn't been possible
for some reason.  We would obviously prefer to ship unpatched kernels with
our systems since, among other things, it means we don't need to maintain an
out-of-tree patch (something which will only get more complex as internal
APIs evolve).  In addition, this approach does peg the r8169 driver in the
resulting system to 1e874e041fc7c222cbd85b20c4406070be1f68, which could have
implications for future debugging, other bug fixes and the like which come
later.

However, you are right in that with the cited patch we have a way to migrate
to something based on either 4.2 or 4.3 (at this point I haven't tested the
woraround combination with anything later).

> > If the decision has been made to leave the regression unfixed, please
> > let me know.
> 
> No such decision that I know of.

Does this mean that a patch to fix the regression will eventually be applied
to mainline (in which case I'll keep watching out for it)?  Or is the
out-of-tree workaround mentioned above considered to be the long term
fix for those who encounter the problem?

Regards
  jonathan
