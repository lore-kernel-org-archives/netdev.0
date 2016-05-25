From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 PATH 2/2] tc action policer: enable timestamp display
Date: Wed, 25 May 2016 06:09:47 -0400
Message-ID: <574579EB.6060306@mojatatu.com>
References: <1464170749-7626-1-git-send-email-jhs@emojatatu.com>
 <1464170749-7626-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:34595 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbcEYKJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 06:09:57 -0400
Received: by mail-ig0-f193.google.com with SMTP id lp2so4498042igb.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 03:09:56 -0700 (PDT)
In-Reply-To: <1464170749-7626-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,
This requires you pull Dave's -net headers.

cheers,
jamal

On 16-05-25 06:05 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   tc/m_police.c | 11 ++++++++++-
>   1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/tc/m_police.c b/tc/m_police.c
> index 8752d4f..cb17c9e 100644
> --- a/tc/m_police.c
> +++ b/tc/m_police.c
> @@ -379,7 +379,16 @@ int print_police(struct action_util *a, FILE *f, struct rtattr *arg)
>   	linklayer = (p->rate.linklayer & TC_LINKLAYER_MASK);
>   	if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
>   		fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b2));
> -	fprintf(f, "\n\tref %d bind %d\n", p->refcnt, p->bindcnt);
> +	fprintf(f, "\n\tref %d bind %d", p->refcnt, p->bindcnt);
> +	if (show_stats) {
> +		if (tb[TCA_POLICE_TM]) {
> +			struct tcf_t *tm = RTA_DATA(tb[TCA_POLICE_TM]);
> +
> +			print_tm(f, tm);
> +		}
> +	}
> +	fprintf(f, "\n");
> +
>
>   	return 0;
>   }
>
