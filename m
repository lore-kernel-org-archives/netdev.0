From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch] net_sched: stack info leak in cbq_dump_wrr()
Date: Mon, 29 Jul 2013 23:20:33 +0200
Message-ID: <20130729212033.GB6386@minipsycho.orion>
References: <20130729193651.GA12525@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130729193651.GA12525@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Jul 29, 2013 at 09:36:51PM CEST, dan.carpenter@oracle.com wrote:
>opt.__reserved isn't cleared so we leak a byte of stack information.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
>diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
>index 71a5688..6398a61 100644
>--- a/net/sched/sch_cbq.c
>+++ b/net/sched/sch_cbq.c
>@@ -1469,6 +1469,7 @@ static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
> 	opt.allot = cl->allot;
> 	opt.priority = cl->priority + 1;
> 	opt.cpriority = cl->cpriority + 1;
>+	opt.__reserved = 0;

There's probably better to zero whole opt at the beginning of the function.
