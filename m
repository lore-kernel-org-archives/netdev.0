From: Baruch Even <baruch@ev-en.org>
Subject: Re: [RFC PATCH] [TCP]: Reworked recovery's TCPCB_LOST marking functions
Date: Tue, 6 Mar 2007 21:42:59 +0200
Message-ID: <20070306194259.GK25760@galon.ev-en.org>
References: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:63375
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933307AbXCFTnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 14:43:00 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070306 14:52]:
> Complete rewrite for update_scoreboard and mark_head_lost. Couple
> of hints became unnecessary because of this change. Changes
> !TCPCB_TAGBITS check from the original to !(S|L) but it shouldn't
> make a difference, and if there ever is an R only skb TCP will
> mark it as LOST too. The algorithm uses some ideas presented by
> David Miller and Baruch Even.
> 
> Seqno lookups require fast lookups that are provided using
> RB-tree patch(+abstraction) from DaveM.
> 
> Signed-off-by: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
> ---
> 
> I'm sorry about poorly chunked diff, is it possible to force git to 
> produce better (large block) diffs when a complete function is rewritten 
> from scratch in the patch (manpage of git-diff-files hints -B bit it did 
> not work, affects whole file rewrites only perhaps)?
> 
> This probably conflicts with the other patches in the rbtree patchset of 
> DaveM (two first are required) because I tested this one (at least the 
> non-timedout part worked) and didn't want some random breakage 
> from the other patches (as such was reported).
> 
>  include/linux/tcp.h      |    6 -
>  include/net/tcp.h        |    6 +
>  net/ipv4/tcp_input.c     |  194 +++++++++++++++++++++++++++++-----------------
>  net/ipv4/tcp_minisocks.c |    1 
>  4 files changed, 130 insertions(+), 77 deletions(-)
> 

[snip]

> +		newtp->highest_sack = treq->snt_isn + 1;

That's the only initialization that you have for highest_sack, I think
that you should initialize it when a loss is detected to the start_seq
of the first packet that wasn't acked.

Didn't review the rest, still need to arrange a proper tree with
preliminary patches to apply it on. Could you note the kernel you based
it on and include all patches applied before it?

Baruch
