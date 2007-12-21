From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed correctly
Date: Fri, 21 Dec 2007 22:49:59 +0900
Message-ID: <d72b7ace0712210549u51043bf8k585fd70e1ded7d8a@mail.gmail.com>
References: <476ACF8A.7060201@gmail.com> <476AD127.2020909@gmail.com>
	 <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
	 <20071221.175352.77874691.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: "=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:31870 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbXLUNuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 08:50:01 -0500
Received: by rv-out-0910.google.com with SMTP id k20so348857rvb.1
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 05:49:59 -0800 (PST)
In-Reply-To: <20071221.175352.77874691.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree.

I mistakenly thought hz in that context must be larger than 1000..
As it's uncertain, your's looks much simpler and better.

(btw, the lines "else .... div = 1" is not needed, is it?)

Thanks,
Satoru SATOH

2007/12/21, YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>:
(snip)
> Why don't you simply use unsigned long long (or maybe uint64_t) here?
>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>
> ---
> diff --git a/ip/iproute.c b/ip/iproute.c
> index f4200ae..db9a3b6 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -509,16 +509,21 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>                             i != RTAX_RTO_MIN)
>                                 fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
>                         else {
> -                               unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
> +                               unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
> +                               unsigned div = 1;
>
> -                               val *= 1000;
>                                 if (i == RTAX_RTT)
> -                                       val /= 8;
> +                                       div = 8;
>                                 else if (i == RTAX_RTTVAR)
> -                                       val /= 4;
> -                               if (val >= hz)
> -                                       fprintf(fp, " %ums", val/hz);
> +                                       div = 4;
>                                 else
> +                                       div = 1;
> +
> +                               val = val * 1000ULL / div;
> +
> +                               if (val >= hz) {
> +                                       fprintf(fp, " %llums", val/hz);
> +                               } else
>                                         fprintf(fp, " %.2fms", (float)val/hz);
>                         }
>                 }
>
> --yoshfuji
