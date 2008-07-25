From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for   qdiscs
Date: Fri, 25 Jul 2008 10:57:48 +0000
Message-ID: <20080725105748.GB10399@ff.dom.local>
References: <20080719233506.12596.59935.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:53497 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbYGYKwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 06:52:43 -0400
Received: by ug-out-1314.google.com with SMTP id h2so672031ugf.16
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 03:52:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080719233506.12596.59935.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20-07-2008 01:35, Jussi Kivilinna wrote:
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
...
> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index 1afe3ee..f1d2f8e 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -370,7 +370,6 @@ static int
>  cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  {
>  	struct cbq_sched_data *q = qdisc_priv(sch);
> -	int len = skb->len;
>  	int uninitialized_var(ret);
>  	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
>  
> @@ -391,7 +390,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	if (ret == NET_XMIT_SUCCESS) {
>  		sch->q.qlen++;
>  		sch->bstats.packets++;
> -		sch->bstats.bytes+=len;
> +		sch->bstats.bytes += qdisc_pkt_len(skb);

Alas I didn't manage to read this earlier, but this type of changes
here and elsewhere in this patch looks wrong to me: we shouldn't
use skb pointer after ->enqueue().

Jarek P.
