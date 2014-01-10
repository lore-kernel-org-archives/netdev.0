From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] HHF qdisc: fix jiffies-time conversion.
Date: Fri, 10 Jan 2014 11:02:45 -0800
Message-ID: <CAB_+Fg7HNc3r8D31WB=U7ZuRuGZdoNbZfsh6Sds-Xq4cRVLY_Q@mail.gmail.com>
References: <1389256800-18809-1-git-send-email-vtlam@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Terry Lam <vtlam@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:52289 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaAJTCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:02:45 -0500
Received: by mail-oa0-f43.google.com with SMTP id m1so5495923oag.2
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 11:02:45 -0800 (PST)
In-Reply-To: <1389256800-18809-1-git-send-email-vtlam@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 12:40 AM, Terry Lam <vtlam@google.com> wrote:
> This is to be compatible with the use of "get_time" (i.e. default
> time unit in us) in iproute2 patch for HHF as requested by Stephen.
>
> Signed-off-by: Terry Lam <vtlam@google.com>
> ---
>  net/sched/sch_hhf.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
> index cf7f614..1cf84a9 100644
> --- a/net/sched/sch_hhf.c
> +++ b/net/sched/sch_hhf.c
> @@ -574,18 +574,18 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
>                 q->hh_flows_limit = nla_get_u32(tb[TCA_HHF_HH_FLOWS_LIMIT]);
>
>         if (tb[TCA_HHF_RESET_TIMEOUT]) {
> -               u32 ms = nla_get_u32(tb[TCA_HHF_RESET_TIMEOUT]);
> +               u32 us = nla_get_u32(tb[TCA_HHF_RESET_TIMEOUT]);
>
> -               q->hhf_reset_timeout = msecs_to_jiffies(ms);
> +               q->hhf_reset_timeout = usecs_to_jiffies(us);
>         }
>
>         if (tb[TCA_HHF_ADMIT_BYTES])
>                 q->hhf_admit_bytes = nla_get_u32(tb[TCA_HHF_ADMIT_BYTES]);
>
>         if (tb[TCA_HHF_EVICT_TIMEOUT]) {
> -               u32 ms = nla_get_u32(tb[TCA_HHF_EVICT_TIMEOUT]);
> +               u32 us = nla_get_u32(tb[TCA_HHF_EVICT_TIMEOUT]);
>
> -               q->hhf_evict_timeout = msecs_to_jiffies(ms);
> +               q->hhf_evict_timeout = usecs_to_jiffies(us);
>         }
>
>         qlen = sch->q.qlen;
> @@ -684,10 +684,10 @@ static int hhf_dump(struct Qdisc *sch, struct sk_buff *skb)
>             nla_put_u32(skb, TCA_HHF_QUANTUM, q->quantum) ||
>             nla_put_u32(skb, TCA_HHF_HH_FLOWS_LIMIT, q->hh_flows_limit) ||
>             nla_put_u32(skb, TCA_HHF_RESET_TIMEOUT,
> -                       jiffies_to_msecs(q->hhf_reset_timeout)) ||
> +                       jiffies_to_usecs(q->hhf_reset_timeout)) ||
>             nla_put_u32(skb, TCA_HHF_ADMIT_BYTES, q->hhf_admit_bytes) ||
>             nla_put_u32(skb, TCA_HHF_EVICT_TIMEOUT,
> -                       jiffies_to_msecs(q->hhf_evict_timeout)) ||
> +                       jiffies_to_usecs(q->hhf_evict_timeout)) ||
>             nla_put_u32(skb, TCA_HHF_NON_HH_WEIGHT, q->hhf_non_hh_weight))
>                 goto nla_put_failure;
>
> --
> 1.8.5.1
>
Acked-by: Nandita Dukkipati <nanditad@google.com>
