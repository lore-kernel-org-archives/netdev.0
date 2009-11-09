From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/8] udp: add a counter into udp_hslot
Date: Mon, 09 Nov 2009 11:39:09 +0100
Message-ID: <87fx8o56eq.fsf@basil.nowhere.org>
References: <4AF72741.5070405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33442 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbZKIKjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 05:39:05 -0500
In-Reply-To: <4AF72741.5070405@gmail.com> (Eric Dumazet's message of "Sun, 08 Nov 2009 21:17:05 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>  
> +/**
> + *	struct udp_hslot - UDP hash slot
> + *
> + *	@head:	head of list of sockets
> + *	@count:	number of sockets in 'head' list
> + *	@lock:	spinlock protecting changes to head/count
> + */
>  struct udp_hslot {
>  	struct hlist_nulls_head	head;
> +	int			count;

Do you really need an int? On 64bit it's free due to the alignment, 
but on 32bit x86 it's costly and you blow up the table considerably,
increasing cache misses.
 
Again it would be nicer if that was a separate smaller table together
with the spinlock.

In theory could also put a short counter into the low level alignment
bits of the pointer and perhaps convert the spinlock to a bitlock?
Then all could collapse into a single pointer.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
