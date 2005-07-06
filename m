From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 6 Jul 2005 02:51:40 +0200
Message-ID: <20050706005140.GT16076@postel.suug.ch>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <42CB2698.2080904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CB2698.2080904@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CB2698.2080904@cosmosbay.com> 2005-07-06 02:32
> Hum... shouldnt it be :
> 
> +			skb = __qdisc_dequeue_head(qdisc, list + prio);
> 

Correct.


> Anyway, the branches misprediction come from the fact that most of packets 
> are queued in the prio=2 list.
> 
> So each time this function is called, a non unrolled version has to pay 2 
> to 5 branches misprediction.
> 
> if ((!skb_queue_empty(list + prio))  /* branch not taken, mispredict when 
> prio=0 */

The !expr implies an unlikely so the prediction should be right and
equal to your unrolling version.

> Maybe we can rewrite the whole thing without branches, examining prio from 
> PFIFO_FAST_BANDS-1 down to 0, at least for modern cpu with conditional mov 
> (cmov)

This would break the whole thing, the qdisc is supposed to try and
dequeue from the highest priority queue (prio=0) first.
