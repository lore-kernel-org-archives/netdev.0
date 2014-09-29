From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH][net-next] ipv4: unnecessary to set err on no_route path
Date: Mon, 29 Sep 2014 15:57:01 +0400
Message-ID: <5429490D.1000004@cogentembedded.com>
References: <1411982198-17416-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:32907 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbaI2L5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 07:57:03 -0400
Received: by mail-la0-f51.google.com with SMTP id pv20so8104650lab.38
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 04:57:01 -0700 (PDT)
In-Reply-To: <1411982198-17416-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/29/2014 1:16 PM, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>

> When the code skips to no_route label, it will skip to local_input at last,
> then err will be reset on the local_input path before exit function.

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/ipv4/route.c |   11 ++++-------
>   1 file changed, 4 insertions(+), 7 deletions(-)

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index d4bd68d..403914b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1704,11 +1704,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>   	fl4.daddr = daddr;
>   	fl4.saddr = saddr;
>   	err = fib_lookup(net, &fl4, &res);
> -	if (err != 0) {
> -		if (!IN_DEV_FORWARD(in_dev))
> -			err = -EHOSTUNREACH;
> +	if (err != 0)
>   		goto no_route;
> -	}
> +

    This extra empty line is not needed.

>
>   	if (res.type == RTN_BROADCAST)
>   		goto brd_input;

WBR, Sergei
