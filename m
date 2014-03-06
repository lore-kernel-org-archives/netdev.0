From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: frag: make sure forced eviction removes all
 frags
Date: Thu, 06 Mar 2014 15:29:35 -0500 (EST)
Message-ID: <20140306.152935.568140961864847527.davem@davemloft.net>
References: <1394125601-27685-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbaCFU3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 15:29:37 -0500
In-Reply-To: <1394125601-27685-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  6 Mar 2014 18:06:41 +0100

> Quoting Alexander Aring:
>   While fragmentation and unloading of 6lowpan module I got this kernel Oops
>   after few seconds:
> 
>   BUG: unable to handle kernel paging request at f88bbc30
>   [..]
>   Modules linked in: ipv6 [last unloaded: 6lowpan]
>   Call Trace:
>    [<c012af4c>] ? call_timer_fn+0x54/0xb3
>    [<c012aef8>] ? process_timeout+0xa/0xa
>    [<c012b66b>] run_timer_softirq+0x140/0x15f
> 
> Problem is that incomplete frags are still around after unload; when
> their frag expire timer fires, we get crash.
> 
> When a netns is removed (also done when unloading module), inet_frag
> calls the evictor with 'force' argument to purge remaining frags.
> 
> The evictor loop terminates when accounted memory ('work') drops to 0
> or the lru-list becomes empty.  However, the mem accounting is done
> via percpu counters and may not be accurate, i.e. loop may terminate
> prematurely.
> 
> Alter evictor to only stop once the lru list is empty when force is
> requested.
> 
> Reported-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> Reported-by: Alexander Aring <alex.aring@gmail.com>
> Tested-by: Alexander Aring <alex.aring@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks.
