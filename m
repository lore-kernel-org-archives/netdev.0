From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [IPROUTE 04/05]: Replace "usec" by "time" in function names
Date: Mon, 15 Jan 2007 11:17:42 +0100
Message-ID: <20070115101742.GB1644@ff.dom.local>
References: <20070110100148.29356.49657.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:54523 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932164AbXAOKPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 05:15:38 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20070110100148.29356.49657.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10-01-2007 11:01, Patrick McHardy wrote:
> [IPROUTE]: Replace "usec" by "time" in function names
> 
> Rename functions containing "usec" since they don't necessarily return
> usec units anymore.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
...
> diff --git a/tc/q_cbq.c b/tc/q_cbq.c
> index 0000a56..913b26a 100644
> --- a/tc/q_cbq.c
> +++ b/tc/q_cbq.c
> @@ -500,17 +500,17 @@ static int cbq_print_opt(struct qdisc_ut
>  	if (lss && show_details) {
>  		fprintf(f, "\nlevel %u ewma %u avpkt %ub ", lss->level, lss->ewma_log, lss->avpkt);
>  		if (lss->maxidle) {
> -			fprintf(f, "maxidle %luus ", tc_core_tick2usec(lss->maxidle>>lss->ewma_log));
> +			fprintf(f, "maxidle %luus ", tc_core_tick2time(lss->maxidle>>lss->ewma_log));

If not necessarily usec, "%luus" could be misleading
here and later. 

...
> diff --git a/tc/q_netem.c b/tc/q_netem.c
> index cfd1799..24fb95e 100644
> --- a/tc/q_netem.c
> +++ b/tc/q_netem.c
> @@ -108,15 +108,15 @@ static int get_ticks(__u32 *ticks, const
>  {
>  	unsigned t;
>  
> -	if(get_usecs(&t, str))
> +	if(get_time(&t, str))
>  		return -1;
>  
> -	if (tc_core_usec2big(t)) {
> +	if (tc_core_time2big(t)) {
>  		fprintf(stderr, "Illegal %d usecs (too large)\n", t);

Like above but usecs.

...
> diff --git a/tc/tc_core.c b/tc/tc_core.c
> index 07dc4ba..e27254e 100644
> --- a/tc/tc_core.c
> +++ b/tc/tc_core.c
> @@ -27,21 +27,21 @@ static __u32 t2us=1;
>  static __u32 us2t=1;
>  static double tick_in_usec = 1;
>  
> -int tc_core_usec2big(long usec)
> +int tc_core_time2big(long time)
>  {
> -	__u64 t = usec;
> +	__u64 t = time;
>  
>  	t *= tick_in_usec;
>  	return (t >> 32) != 0;
>  }
>  
>  
> -long tc_core_usec2tick(long usec)
> +long tc_core_time2tick(long time)
>  {
> -	return usec*tick_in_usec;
> +	return time*tick_in_usec;
>  }
>  
> -long tc_core_tick2usec(long tick)
> +long tc_core_tick2time(long tick)
>  {
>  	return tick/tick_in_usec;
>  }

Similarly (tick_in_time)?

Regards,
Jarek P.
