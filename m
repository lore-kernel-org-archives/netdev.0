From: Thomas Graf <tgraf@suug.ch>
Subject: Re: BUG: HTB?
Date: Thu, 21 Apr 2005 21:56:05 +0200
Message-ID: <20050421195605.GJ577@postel.suug.ch>
References: <7bca1cb50504211221655fd54c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Asim Shankar <asimshankar@gmail.com>
Content-Disposition: inline
In-Reply-To: <7bca1cb50504211221655fd54c@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

* Asim Shankar <7bca1cb50504211221655fd54c@mail.gmail.com> 2005-04-21 14:21
> Specifically, in the lines:
> if (cl == HTB_DIRECT) {
>         /* enqueue to helper queue */
>         if (q->direct_queue.qlen < q->direct_qlen) {
>                 __skb_queue_tail(&q->direct_queue, skb);
>                 q->direct_pkts++;
>         }
> }
> 
> If a packet is classified as HTB_DIRECT but the direct_queue is
> already full, then the packet doesn't get enqueued but sch->q.qlen++
> will happen a few lines later. Overflowing of the direct_queue
> probably rarely happens in practice, but I was playing around and
> noticed it happen in some corner cases of my testing.

Yes, that's a bug.

> Should the packet be dropped instead? Like:
> 
> if (cl == HTB_DIRECT) {
>         /* enqueue to helper queue */
>         if (q->direct_queue.qlen < q->direct_qlen) {
>                 __skb_queue_tail(&q->direct_queue, skb);
>                 q->direct_pkts++;
>         } else {
>                sch->qstats.drops++;
>                 kfree_skb(skb);
>                 return NET_XMIT_DROP;
>        }
> }

Can you send a patch? 
