From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: init_timer_deferrable conversion
Date: Mon, 17 Dec 2007 09:55:04 +0100
Message-ID: <20071217095504.b02241ee.dada1@cosmosbay.com>
References: <Pine.LNX.4.64.0712162149220.4622@mini.warudkars.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: parag.warudkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:52904 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764192AbXLQJ55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 04:57:57 -0500
In-Reply-To: <Pine.LNX.4.64.0712162149220.4622@mini.warudkars.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 22:00:23 -0500 (EST)
Parag Warudkar <parag.warudkar@gmail.com> wrote:

> In my quest to get the wake-ups from idle per second down to bare minimum, 
> I noticed 3 places in the kernel that could benefit from 
> using init_timer_deferrable() instead of init_timer() -
> 
> a) drivers/net/sky2.c - watchdog_timer. This was showing up high on 
> Powertop's list of things that cause routine wakeups from idle. After 
> converting to init_timer_deferrable() the wakeups went down and this one 
> no longer shows up in powertop's list. 25% reduction.
> 
> b) kernel/time/clocksource.c - watchdog_timer - same story as sky2.c
> 
> c) net/core/neighbour.c - gc_timer - Most benefit from deferrable timer.

neigh_periodic_timer() is actually doing almost nothing per round, since it
looks only one slot of hash table. We could probably convert it to a
workqueue and scan whole table at once.

> 
> I am running a kernel with above changes and haven't noticed any immediate 
> problems and the wakeups-from-idle have gone down from 5-7 to mere 1-2 per 
> second.
> 
> Is there any reason not to make the above timers deferrable - corner 
> cases, other side effects? If not then I will submit a patch.
> 
> Thanks
> 
> Parag
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
