From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] SFQ: use net_random
Date: Fri, 18 Jan 2008 20:18:20 -0800
Message-ID: <20080119041820.GA24840@linux.vnet.ibm.com>
References: <20080118144309.3530ed2f@deepthought> <20080118144730.7878f12a@deepthought>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60816 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760723AbYASETU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 23:19:20 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0J3Fxja032022
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 22:15:59 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0J4IpRG100896
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 21:19:01 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0J4IpVK006066
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 21:18:51 -0700
Content-Disposition: inline
In-Reply-To: <20080118144730.7878f12a@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2008 at 02:47:30PM -0800, Stephen Hemminger wrote:
> SFQ doesn't need true random numbers, it is only using them to salt
> a hash. Therefore it is better to use net_random() and avoid any possible
> problems with depleting the entropy pool.

The random-number algorithm used by net_random() certainly does appear
to be considerably stronger than the one I used to generate the results
in the 1990 paper.  ;-)

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
> 
> 
> --- a/net/sched/sch_sfq.c	2008-01-17 09:00:58.000000000 -0800
> +++ b/net/sched/sch_sfq.c	2008-01-17 09:03:26.000000000 -0800
> @@ -386,7 +386,7 @@ static void sfq_perturbation(unsigned lo
>  	struct Qdisc *sch = (struct Qdisc*)arg;
>  	struct sfq_sched_data *q = qdisc_priv(sch);
> 
> -	get_random_bytes(&q->perturbation, 4);
> +	q->perturbation = net_random();
> 
>  	if (q->perturb_period)
>  		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
> @@ -415,7 +415,7 @@ static int sfq_change(struct Qdisc *sch,
>  	del_timer(&q->perturb_timer);
>  	if (q->perturb_period) {
>  		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
> -		get_random_bytes(&q->perturbation, 4);
> +		q->perturbation = net_random();
>  	}
>  	sch_tree_unlock(sch);
>  	return 0;
> @@ -443,7 +443,7 @@ static int sfq_init(struct Qdisc *sch, s
>  	if (opt == NULL) {
>  		q->quantum = psched_mtu(sch->dev);
>  		q->perturb_period = 0;
> -		get_random_bytes(&q->perturbation, 4);
> +		q->perturbation = net_random();
>  	} else {
>  		int err = sfq_change(sch, opt);
>  		if (err)
