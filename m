From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] tcp: make undo_cwnd mandatory for congestion
 modules
Date: Fri, 18 Nov 2016 19:54:34 +0100
Message-ID: <20161118185434.GB18071@breakpoint.cc>
References: <1479387411-9830-1-git-send-email-fw@strlen.de>
 <20161118.134304.1574614508508170507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, edumazet@google.com,
        ycheng@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:60432 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751986AbcKRS5D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:57:03 -0500
Content-Disposition: inline
In-Reply-To: <20161118.134304.1574614508508170507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Thu, 17 Nov 2016 13:56:51 +0100
> 
> > The undo_cwnd fallback in the stack doubles cwnd based on ssthresh,
> > which un-does reno halving behaviour.
> > 
> > It seems more appropriate to let congctl algorithms pair .ssthresh
> > and .undo_cwnd properly. Add a 'tcp_reno_undo_cwnd' function and wire it
> > up for all congestion algorithms that used to rely on the fallback.
> > 
> > highspeed, illinois, scalable, veno and yeah use 'reno undo' while their
> > .ssthresh implementation doesn't halve the slowstart threshold, this
> > might point to similar issue as the one fixed for dctcp in
> > ce6dd23329b1e ("dctcp: avoid bogus doubling of cwnd after loss").
> > 
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> If you really suspect that highspeed et al. need to implement their own
> undo_cwnd instead of using the default reno fallback, I would really
> rather that this gets either fixed or explicitly marked as likely wrong
> (in an "XXX" comment or similar).

Ok, fair enough.  I am not familiar with these algorithms, I will check
what they're doing in more detail and if absolutely needed resubmit this
patch with XXX/FIXME/TODO comments added.

> Otherwise nobody is going to remember this down the road.

Agreed.
