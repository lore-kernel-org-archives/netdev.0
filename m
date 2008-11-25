From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] tc: check for errors from gen_replace_estimator
Date: Tue, 25 Nov 2008 19:28:47 +0100
Message-ID: <492C43DF.1040703@trash.net>
References: <20081125101656.52348bdd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33370 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbYKYS26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 13:28:58 -0500
In-Reply-To: <20081125101656.52348bdd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> gen_replace_estimator can return errors, but they were being ignored.
> 
> --- a/net/sched/sch_hfsc.c	2008-11-25 10:02:05.000000000 -0800
> +++ b/net/sched/sch_hfsc.c	2008-11-25 10:07:21.000000000 -0800
> @@ -1035,10 +1035,10 @@ hfsc_change_class(struct Qdisc *sch, u32
>  		sch_tree_unlock(sch);
>  
>  		if (tca[TCA_RATE])
> -			gen_replace_estimator(&cl->bstats, &cl->rate_est,
> +			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
>  					      qdisc_root_sleeping_lock(sch),
>  					      tca[TCA_RATE]);
> -		return 0;
> +		return err;

At this point we've already made changes to the class, so
returning an error without undoing them is wrong.

I'd suggest to move the estimator replacement up a bit, the
other changes can't fail.

There's also gen_new_estimator() that should be treated
similary for consistency.
