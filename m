From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netns netfilter: semi-rewrite of /proc/net/foo_tables_*
Date: Wed, 30 Jan 2008 16:17:10 +0100
Message-ID: <47A094F6.6010406@trash.net>
References: <20080125164314.GE6028@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53647 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbYA3PR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 10:17:28 -0500
In-Reply-To: <20080125164314.GE6028@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Argh, there are many small but still wrong things with /proc/net/*_tables_*
> so I decided to do overhaul simultaneously making it more suitable for
> per-netns /proc/net/*_tables_* implementation.
> 
> Fix
> a) xt_get_idx() duplicating now standard seq_list_start/seq_list_next
>    iterators
> b) tables/matches/targets list was chosen again and again on every ->next
> c) multiple useless "af >= NPROTO" checks -- we simple don't supply invalid
>    AFs there and registration function should BUG_ON instead.
>    
>    Regardless, the one in ->next() is the most useless -- ->next doesn't
>    run at all if ->start fails.
> d) Don't use mutex_lock_interruptible() -- it can fail and ->stop is
>    executed even if ->start failed, so unlock without lock is possible.
> 
> As side effect, streamline code by splitting xt_tgt_ops into xt_target_ops,
> xt_matches_ops, xt_tables_ops.
> 
> xt_tables_ops hooks will be changed by per-netns code. Code of
> xt_matches_ops, xt_target_ops is identical except the list chosen for
> iterating, but I think consolidating code for two files not worth it
> given "<< 16" hacks needed for it.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied, and I also removed the now unused TABLE/TARGET/MATCH enum.
