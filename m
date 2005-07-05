From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 5 Jul 2005 13:51:08 +0200
Message-ID: <20050705115108.GE16076@postel.suug.ch>
References: <20050704.154712.63128211.davem@davemloft.net> <42C9BE69.2070008@cosmosbay.com> <42C9BEF6.4080402@cosmosbay.com> <20050704.160140.21591849.davem@davemloft.net> <42CA390C.9000801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CA390C.9000801@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CA390C.9000801@cosmosbay.com> 2005-07-05 09:38
> [NET] : unroll a small loop in pfifo_fast_dequeue(). Compiler generates 
> better code.
> 	(Using skb_queue_empty() to test the queue is faster than trying to 
> 	__skb_dequeue())
> 	oprofile says this function uses now 0.29% instead of 1.22 %, on a 
> 	x86_64 target.

I think this patch is pretty much pointless. __skb_dequeue() and
!skb_queue_empty() should produce almost the same code and as soon
as you disable profiling and debugging you'll see that the compiler
unrolls the loop itself if possible.
