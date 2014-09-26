From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/5] net: tcp: add flag for ca to indicate
 that ECN is required
Date: Fri, 26 Sep 2014 16:20:29 -0400 (EDT)
Message-ID: <20140926.162029.1735467343159695433.davem@davemloft.net>
References: <1411248562-26581-3-git-send-email-fw@strlen.de>
	<20140922.163357.553905454314637491.davem@davemloft.net>
	<20140923091105.GB13394@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	glenn.judd@morganstanley.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422641AbaIZUUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:20:33 -0400
In-Reply-To: <20140923091105.GB13394@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 23 Sep 2014 11:11:05 +0200

> Thanks for your feedback! We have actually thought about that for
> quite a while before starting on the implementation, and concluded
> that the behaviour is actually fine as is for three reasons:
> 
> 1) DCTCP is very tighly coupled to the ECN machinery as described
>    in the paper. Not having ECN enabled and nevertheless allowing
>    DCTCP (if we would implement above feedback) would just make it
>    fallback to Reno, which would not be useful in the first place.
>    So an administrator would rather not load DCTCP to the available
>    congestion control modules in the first place in this case.
> 
> 2) Right now an administrator can choose to use DCTCP only for a
>    particular process, and still avoid exposing ECN to the outside
>    world for every other process.
> 
> 3) An unpriviledged user would not be able to use DCTCP *unless*
>    an administrator has explicitly allowed to use it. This is being
>    reflected since Stephen's commit ce7bc3bf15cb ("[TCP]: Restrict
>    congestion control choices.") where only Reno or the currently
>    compiled-in default choice is non-restricted.
> 
> If you nevertheless think that it is useful to include above feedback
> to overcome your objection, we could just add a check for tcp_ecn
> sysctl being set to 1 for the initialization of the congestion control
> ops of the socket and otherwise fall back to Reno.

Ok, I'm convinced (for now).

Please resubmit this series and I'll apply it, thanks.
