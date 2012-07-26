From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 15:13:12 -0700
Message-ID: <20120726151312.2f3d9e02@nehalam.linuxnetplumber.net>
References: <1343324633.2626.11801.camel@edumazet-glaptop>
	<1343324896.2626.11808.camel@edumazet-glaptop>
	<CAKgT0UfZmK=gSSn+1Z8=KpW9ckVAJJgQg1+5NdO9SKfWv8GiCg@mail.gmail.com>
	<20120726.140601.1137230112117936793.davem@davemloft.net>
	<CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37082 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284Ab2GZWNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2012 18:13:36 -0400
In-Reply-To: <CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jul 2012 15:03:39 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Thu, Jul 26, 2012 at 2:06 PM, David Miller <davem@davemloft.net> wrote:
> > From: Alexander Duyck <alexander.duyck@gmail.com>
> > Date: Thu, 26 Jul 2012 11:26:26 -0700
> >
> >> The previous results were with a slight modifications to your earlier
> >> patch.  With this patch applied I am seeing 10.4Mpps with 8 queues,
> >> reaching a maximum of 11.6Mpps with 9 queues.
> >
> > For fun you might want to see what this patch does for your tests,
> > it should cut the number of fib_table_lookup() calls roughly in half.
> 
> So with your patch, Eric's patch, and this most recent patch we are
> now at 11.8Mpps with 8 or 9 queues.  At this point I am staring to hit
> the hardware limits since 82599 will typically max out at about 12Mpps
> w/ 9 queues.
> 
> Here is the latest perf results with all of these patches in place.
> As you predicted your patch essentially cut the lookup overhead in
> half:
>     10.65%  [k] ixgbe_poll
>      7.77%  [k] fib_table_lookup
>      6.21%  [k] ixgbe_xmit_frame_ring
>      6.08%  [k] __netif_receive_skb
>      4.41%  [k] _raw_spin_lock
>      3.95%  [k] kmem_cache_free
>      3.30%  [k] build_skb
>      3.17%  [k] memcpy
>      2.96%  [k] dev_queue_xmit
>      2.79%  [k] ip_finish_output
>      2.66%  [k] kmem_cache_alloc
>      2.57%  [k] check_leaf
>      2.52%  [k] ip_route_input_noref
>      2.50%  [k] netdev_alloc_frag
>      2.17%  [k] ip_rcv
>      2.16%  [k] __phys_addr
> 
> I will probably do some more poking around over the next few days in
> order to get my head around the fib_table_lookup overhead.
> 
> Thanks,
> 
> Alex
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The fib trie stats are global, you may want to either disable CONFIG_IP_FIB_TRIE_STATS
or convert them to per-cpu.
