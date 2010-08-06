From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sfq: add dummy bind/unbind handles
Date: Sat, 07 Aug 2010 01:17:07 +0200
Message-ID: <4C5C97F3.3010604@gmail.com>
References: <20100806193548.007978639@vyatta.com>	<20100806193558.580890552@vyatta.com>	<4C5C7D9F.4040303@gmail.com>	<20100806145818.66d389eb@nehalam> <20100806152313.43abc30b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Franchoze Eric <franchoze@yandex.ru>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38048 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834Ab0HFXRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 19:17:13 -0400
Received: by bwz3 with SMTP id 3so271638bwz.19
        for <netdev@vger.kernel.org>; Fri, 06 Aug 2010 16:17:12 -0700 (PDT)
In-Reply-To: <20100806152313.43abc30b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote, On 07.08.2010 00:23:

> Applying a filter to an SFQ qdisc would cause null dereference
> in tcf_bind_filter because although SFQ is classful it didn't
> have all the necessary equipment.
> 
> Better alternative to changing tcf_bind API is to just fix
> SFQ.  This should go to net-2.6 and stable.
> 

Hmm... FYI, actually I've sent already a similar patch to the
original bug report thread (except .unbind_tcf method which
doesn't matter for fixing this bug, so should be rather
implemented in a separate patch, if needed at all in this
case).

Jarek P.

> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/sched/sch_sfq.c	2010-08-06 15:07:26.552820159 -0700
> +++ b/net/sched/sch_sfq.c	2010-08-06 15:14:24.458287452 -0700
> @@ -502,6 +502,10 @@ static unsigned long sfq_get(struct Qdis
>  	return 0;
>  }
>  
> +static void sfq_put(struct Qdisc *q, unsigned long cl)
> +{
> +}
> +
>  static struct tcf_proto **sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);
> @@ -511,6 +515,12 @@ static struct tcf_proto **sfq_find_tcf(s
>  	return &q->filter_list;
>  }
>  
> +static unsigned long sfq_bind_tcf(struct Qdisc *sch, unsigned long parent,
> +				  u32 cl)
> +{
> +	return 0;
> +}
> +
>  static int sfq_dump_class(struct Qdisc *sch, unsigned long cl,
>  			  struct sk_buff *skb, struct tcmsg *tcm)
>  {
> @@ -556,6 +566,8 @@ static void sfq_walk(struct Qdisc *sch, 
>  static const struct Qdisc_class_ops sfq_class_ops = {
>  	.get		=	sfq_get,
>  	.tcf_chain	=	sfq_find_tcf,
> +	.bind_tcf	=	sfq_bind_tcf,
> +	.unbind_tcf	=	sfq_put,
>  	.dump		=	sfq_dump_class,
>  	.dump_stats	=	sfq_dump_class_stats,
> 


