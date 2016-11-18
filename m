From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tcp: make undo_cwnd mandatory for congestion
 modules
Date: Fri, 18 Nov 2016 13:43:04 -0500 (EST)
Message-ID: <20161118.134304.1574614508508170507.davem@davemloft.net>
References: <1479387411-9830-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
        ncardwell@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbcKRSnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:43:09 -0500
In-Reply-To: <1479387411-9830-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 17 Nov 2016 13:56:51 +0100

> The undo_cwnd fallback in the stack doubles cwnd based on ssthresh,
> which un-does reno halving behaviour.
> 
> It seems more appropriate to let congctl algorithms pair .ssthresh
> and .undo_cwnd properly. Add a 'tcp_reno_undo_cwnd' function and wire it
> up for all congestion algorithms that used to rely on the fallback.
> 
> highspeed, illinois, scalable, veno and yeah use 'reno undo' while their
> .ssthresh implementation doesn't halve the slowstart threshold, this
> might point to similar issue as the one fixed for dctcp in
> ce6dd23329b1e ("dctcp: avoid bogus doubling of cwnd after loss").
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

If you really suspect that highspeed et al. need to implement their own
undo_cwnd instead of using the default reno fallback, I would really
rather that this gets either fixed or explicitly marked as likely wrong
(in an "XXX" comment or similar).

Otherwise nobody is going to remember this down the road.
