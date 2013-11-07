From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/3] net_sched: tbf: support of 64bit rates
Date: Thu, 07 Nov 2013 18:25:39 +0400
Message-ID: <527BA2E3.5090905@cogentembedded.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com> <1383790412-41944-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:51874 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab3KGOZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 09:25:47 -0500
Received: by mail-lb0-f177.google.com with SMTP id u14so484866lbd.22
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 06:25:46 -0800 (PST)
In-Reply-To: <1383790412-41944-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-11-2013 6:13, Yang Yingliang wrote:

> With psched_ratecfg_precompute(), tbf can deal with 64bit rates.
> Add two new attributes so that tc can use them to break the 32bit
> limit.

> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
[...]

> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index b057122..b736517 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
[...]
> @@ -402,6 +409,13 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
>   	opt.buffer = PSCHED_NS2TICKS(q->buffer);
>   	if (nla_put(skb, TCA_TBF_PARMS, sizeof(opt), &opt))
>   		goto nla_put_failure;
> +	if ((q->rate.rate_bytes_ps >= (1ULL << 32)) &&
> +			nla_put_u64(skb, TCA_TBF_RATE64, q->rate.rate_bytes_ps))
> +		goto nla_put_failure;
> +	if (q->peak_present &&
> +			(q->peak.rate_bytes_ps >= (1ULL << 32)) &&
> +			nla_put_u64(skb, TCA_TBF_PRATE64, q->peak.rate_bytes_ps))
> +		goto nla_put_failure;

    According to the networking coding style, the *if* continuation lines 
should start under the next character after (.

WBR, Sergei
