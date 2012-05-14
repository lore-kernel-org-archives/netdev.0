From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] net: codel: fix build errors
Date: Mon, 14 May 2012 15:05:44 -0700
Message-ID: <20120514150544.6b17d3c5@nehalam.linuxnetplumber.net>
References: <1337032626-7104-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dave.taht@bufferbloat.net,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49099 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757855Ab2ENWFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 18:05:47 -0400
In-Reply-To: <1337032626-7104-1-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 May 2012 23:57:06 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> Fix the following build error:
> 
> net/sched/sch_fq_codel.c: In function 'fq_codel_dump_stats':
> net/sched/sch_fq_codel.c:464:3: error: unknown field 'qdisc_stats' specified in initializer
> net/sched/sch_fq_codel.c:464:3: warning: missing braces around initializer
> net/sched/sch_fq_codel.c:464:3: warning: (near initialization for 'st.<anonymous>')
> net/sched/sch_fq_codel.c:465:3: error: unknown field 'qdisc_stats' specified in initializer
> net/sched/sch_fq_codel.c:465:3: warning: excess elements in struct initializer
> net/sched/sch_fq_codel.c:465:3: warning: (near initialization for 'st')
> net/sched/sch_fq_codel.c:466:3: error: unknown field 'qdisc_stats' specified in initializer
> net/sched/sch_fq_codel.c:466:3: warning: excess elements in struct initializer
> net/sched/sch_fq_codel.c:466:3: warning: (near initialization for 'st')
> net/sched/sch_fq_codel.c:467:3: error: unknown field 'qdisc_stats' specified in initializer
> net/sched/sch_fq_codel.c:467:3: warning: excess elements in struct initializer
> net/sched/sch_fq_codel.c:467:3: warning: (near initialization for 'st')
> make[1]: *** [net/sched/sch_fq_codel.o] Error 1
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/sched/sch_fq_codel.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index a7b3754..337ff20 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -461,13 +461,14 @@ static int fq_codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
>  	struct fq_codel_sched_data *q = qdisc_priv(sch);
>  	struct tc_fq_codel_xstats st = {
>  		.type				= TCA_FQ_CODEL_XSTATS_QDISC,
> -		.qdisc_stats.maxpacket		= q->cstats.maxpacket,
> -		.qdisc_stats.drop_overlimit	= q->drop_overlimit,
> -		.qdisc_stats.ecn_mark		= q->cstats.ecn_mark,
> -		.qdisc_stats.new_flow_count	= q->new_flow_count,
>  	};
>  	struct list_head *pos;
>  
> +	st.qdisc_stats.maxpacket = q->cstats.maxpacket;
> +	st.qdisc_stats.drop_overlimit = q->drop_overlimit;
> +	st.qdisc_stats.ecn_mark = q->cstats.ecn_mark;
> +	st.qdisc_stats.new_flow_count = q->new_flow_count;
> +
>  	list_for_each(pos, &q->new_flows)
>  		st.qdisc_stats.new_flows_len++;
>  

Cleaner and simpler to just use nested initialization.
 	struct tc_fq_codel_xstats st = {
		.type				= TCA_FQ_CODEL_XSTATS_QDISC,
		.qdisc_stats = {
			.maxpacket	= q->cstats.maxpacket,
			.drop_overlimit	= q->drop_overlimit,
			.ecn_mark	= q->cstats.ecn_mark,
			.new_flow_count	= q->new_flow_count,
		},
	};
