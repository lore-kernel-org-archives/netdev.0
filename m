From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] bridge: 64bit rx/tx counters
Date: Mon, 9 Aug 2010 21:47:40 -0700
Message-ID: <20100809214740.c5d186d2.akpm@linux-foundation.org>
References: <1276531162.2478.121.camel@edumazet-laptop>
	<20100614.231412.39191304.davem@davemloft.net>
	<1276596856.2541.84.camel@edumazet-laptop>
	<1276598376.2541.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	Nick Piggin <npiggin@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60160 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751244Ab0HJEqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 00:46:11 -0400
In-Reply-To: <1276598376.2541.93.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jun 2010 12:39:36 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Note : should be applied after "net: Introduce 
> u64_stats_sync infrastructure", if accepted.
> 
> 
> Thanks
> 
> [PATCH net-next-2.6] bridge: 64bit rx/tx counters
> 
> Use u64_stats_sync infrastructure to provide 64bit rx/tx 
> counters even on 32bit hosts.
> 
> It is safe to use a single u64_stats_sync for rx and tx,
> because BH is disabled on both, and we use per_cpu data.
>

Oh for fuck's sake.  Will you guys just stop adding generic kernel
infrastructure behind everyone's backs?

Had I actually been aware that this stuff was going into the tree I'd
have pointed out that the u64_stats_* api needs renaming. 
s/stats/counter/ because it has no business assuming that the counter
is being used for statistics.


And all this open-coded per-cpu counter stuff added all over the place.
Were percpu_counters tested or reviewed and found inadequate and unfixable?
If so, please do tell.

