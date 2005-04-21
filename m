From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] - sch_htb: Drop packet when direct queue overflows
Date: Thu, 21 Apr 2005 23:54:40 +0200
Message-ID: <20050421215440.GL577@postel.suug.ch>
References: <7bca1cb50504211221655fd54c@mail.gmail.com> <20050421195605.GJ577@postel.suug.ch> <7bca1cb505042113417a5d9f59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Asim Shankar <asimshankar@gmail.com>
Content-Disposition: inline
In-Reply-To: <7bca1cb505042113417a5d9f59@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[CCed Martin Devera]

* Asim Shankar <7bca1cb505042113417a5d9f59@mail.gmail.com> 2005-04-21 15:41
> Patched pasted and attached:

For patch formatting details see http://linux.yyz.us/patch-format.html
A short description of the patch would be helpful.

Besides of that...

Signed-off-by: Thomas Graf <tgraf@suug.ch>

> --- linux-2.6.11.7/net/sched/sch_htb.c	2005-04-07 13:57:45.000000000 -0500
> +++ linux-2.6.11.7-new/net/sched/sch_htb.c	2005-04-21 14:17:36.272065816 -0500
> @@ -717,6 +717,10 @@
>  	if (q->direct_queue.qlen < q->direct_qlen) {
>  	    __skb_queue_tail(&q->direct_queue, skb);
>  	    q->direct_pkts++;
> +	} else {
> +	    kfree_skb (skb);

Could you write this without the whitespace?

> +	    sch->qstats.drops++;
> +	    return NET_XMIT_DROP;
>  	}
>  #ifdef CONFIG_NET_CLS_ACT
>      } else if (!cl) {

Thanks.
