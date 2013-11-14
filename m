From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH iproute2] htb: support 64bit rates
Date: Thu, 14 Nov 2013 16:12:00 +0800
Message-ID: <528485D0.5030300@huawei.com>
References: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:52723 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab3KNIMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 03:12:46 -0500
In-Reply-To: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/13 6:34, Eric Dumazet wrote:

[...]
> @@ -256,6 +270,7 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>  	struct tc_htb_glob *gopt;
>  	double buffer,cbuffer;
>  	unsigned int linklayer;
> +	__u64 rate64, ceil64;
>  	SPRINT_BUF(b1);
>  	SPRINT_BUF(b2);
>  	SPRINT_BUF(b3);
> @@ -275,12 +290,25 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>  			if (show_details)
>  				fprintf(f, "quantum %d ", (int)hopt->quantum);
>  		}
> -		fprintf(f, "rate %s ", sprint_rate(hopt->rate.rate, b1));
> +
> +		rate64 = hopt->rate.rate;
> +		if (tb[TCA_HTB_RATE64] &&
> +		    RTA_PAYLOAD(tb[TCA_HTB_RATE64]) >= sizeof(rate64)) {
> +			rate64 = rta_getattr_u64(tb[TCA_HTB_RATE64]);
> +		}
> +

If RTA_PAYLOAD(tb[TCA_HTB_RATE64]) < sizeof(rate64),
it means something wrong, it don't need to continue,
"return -1" would be better.

Regards,
Yang

> +		ceil64 = hopt->ceil.rate;
> +		if (tb[TCA_HTB_CEIL64] &&
> +		    RTA_PAYLOAD(tb[TCA_HTB_CEIL64]) >= sizeof(ceil64))
> +			ceil64 = rta_getattr_u64(tb[TCA_HTB_CEIL64]);
> +
[...]
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
