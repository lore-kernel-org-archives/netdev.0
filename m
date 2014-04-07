From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Inconsistent perf top output
Date: Sun, 06 Apr 2014 21:10:34 -0700
Message-ID: <87ioqlkced.fsf@tassilo.jf.intel.com>
References: <645781396449095@web21h.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-perf-users@vger.kernel.org, netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <linux-perf-users-owner@vger.kernel.org>
In-Reply-To: <645781396449095@web21h.yandex.ru> (Oleg A. Arkhangelsky's
	message of "Wed, 02 Apr 2014 18:31:35 +0400")
Sender: linux-perf-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru> writes:

Better asked on netdev. Copied here. It's unlikely to be a perf problem.
You better specify what kernel version you have.

> Hello,
>
> I'm profiling Linux IP packet forwarding performance. In common case I see this
> functions eating most of CPU cycles.
>
> 13735.00 22.5% build_skb  
> 5138.00   8.4% ipt_do_table 
> 4750.00   7.8% fib_table_lookup
> 3519.00   5.8% ixgbe_clean_rx_irq
> 2836.00   4.6% nf_iterate
> 1530.00   2.5% dev_queue_xmit
>
> Looks good. But accidentally I run tcpdump program on one of the NICs related
> to my test. After killing tcpdump I see that top is different:
>
> 6362.00 10.3% fib_table_lookup
> 6227.00 10.1% ipt_do_table
> 4300.00  7.0% ixgbe_clean_rx_irq
> 3771.00  6.1% nf_iterate
> 3284.00  5.3% build_skb
> 2179.00  3.5% ixgbe_xmit_frame_ring
>
> Dramatic change in build_skb() cpu cycles. But tcpdump is not active anymore.
> More than this, if I stop pktgen on traffic generator PC for a few seconds and
> start it again without any other changes, I see that build_skb() is top offender
> again. Running tcpdump again and killing it move fib_table_lookup() or
> ipt_do_table() (they are pretty same in cpu cycles) to the top. So this behavior
> is reproducible.
>
> I just have no sane explanation to such strange behavior. Maybe someone have?
>
> Thank you!

-- 
ak@linux.intel.com -- Speaking for myself only
