From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Wed, 15 Apr 2015 09:24:35 -0700
Message-ID: <20150415162434.GA3490@Alexeis-MBP.westell.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <20150410132205.GF23070@casper.infradead.org>
 <20150410200901.GB5968@salvia>
 <20150412.211421.1771298417488412635.davem@davemloft.net>
 <20150413201913.GD20275@acer.localdomain>
 <552D07C4.1020509@mojatatu.com>
 <552D2E52.8020303@intel.com>
 <20150414153613.GA2781@Alexeis-MBP.westell.com>
 <552E14B4.7060907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, pablo@netfilter.org,
	tgraf@suug.ch, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552E14B4.7060907@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 12:35:16AM -0700, John Fastabend wrote:
>
> I'll dig up my scripts and post them to github this weekend. They
> are a bit organized and all over the place at the moment.
> 
> Maybe we can build a master repository. I know there a lot of different
> scripts running around, for example I already collected a few from
> Jamal and I think Cong must have some as well.

great. let's start building a proper testsuite.

> diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
> index 4cdbfb8..a2542ac 100644
> --- a/net/sched/sch_ingress.c
> +++ b/net/sched/sch_ingress.c
> @@ -69,7 +69,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct
> Qdisc *sch)
>  	switch (result) {
>  	case TC_ACT_SHOT:
>  		result = TC_ACT_SHOT;
> -		qdisc_qstats_drop(sch);
> +		qdisc_qstats_drop_cpu(sch);

Your quick patch missed updating:
- qdisc_bstats_update(sch, skb);
+ qdisc_bstats_update_cpu(sch, skb);

I've tried the same :)

