From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 09:00:35 +0000
Message-ID: <20090825090035.GB7879@ff.dom.local>
References: <20090825062203.GA5381@ff.dom.local> <200908251034.09581.denys@visp.net.lb> <20090825084306.GA7879@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58436 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbZHYJAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 05:00:39 -0400
Received: by bwz19 with SMTP id 19so1922300bwz.37
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 02:00:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090825084306.GA7879@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 08:43:06AM +0000, Jarek Poplawski wrote:
...
> since these 64 bits will be needed soon for higher rates anyway, I
> guess we could try some change like the patch below, if you find it
> works for you (I didn't test it yet.)

Hmm... Don't bother testing it! There is needed something more...

Jarek P.

> ---
> 
>  net/sched/sch_tbf.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index e22dfe8..2c74450 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -160,8 +160,8 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
>  
>  	if (skb) {
>  		psched_time_t now;
> -		long toks;
> -		long ptoks = 0;
> +		long long toks;
> +		long long ptoks = 0;
>  		unsigned int len = qdisc_pkt_len(skb);
>  
>  		now = psched_get_time();
> 
> 
