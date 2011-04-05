From: Florian Westphal <fw@strlen.de>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Wed, 6 Apr 2011 01:42:16 +0200
Message-ID: <20110405234216.GD32579@Chamillionaire.breakpoint.cc>
References: <20110404194856.GA3720@dannf.org>
 <4D9A23BC.4010505@trash.net>
 <1301949477.3021.55.camel@edumazet-laptop>
 <1301957293.3021.191.camel@edumazet-laptop>
 <1301984679.3021.655.camel@edumazet-laptop>
 <1301987879.3021.714.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, dann frazier <dannf@dannf.org>,
	netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42359 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751859Ab1DEXmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 19:42:19 -0400
Content-Disposition: inline
In-Reply-To: <1301987879.3021.714.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> [PATCH] netfilter: fix ebtables
> 
> commit 255d0dc34068a976 (netfilter: x_table: speedup compat operations)
> made ebtables not working anymore.
> 
> 1) xt_compat_calc_jump() is not an exact match lookup, and 
> 2) compat_table_info() has a typo in xt_compat_init_offsets() call
> 3) compat_do_replace() misses a xt_compat_init_offsets() call

Looks good, but

> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 893669c..c66aa80 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1766,7 +1766,7 @@ static int compat_table_info(const struct ebt_table_info *info,
>  
>  	newinfo->entries_size = size;
>  
> -	xt_compat_init_offsets(AF_INET, info->nentries);
> +	xt_compat_init_offsets(NFPROTO_BRIDGE, info->nentries /* + 4*/);

using ninfo->nentries does not always work because ebtables compat
can call xt_compat_add_offset() more than once per entry.

That is of course not necessary; the ebt compat code should do better.
I plan to look at this in the evening.
