From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ipv6: Fixed up ipsec packet be re-routing issue
Date: Thu, 22 May 2014 16:21:15 +0400
Message-ID: <537DEBBB.60100@cogentembedded.com>
References: <1400742346-24727-1-git-send-email-huizhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, nickcave.zhang@gmail.com
To: huizhang <huizhang@marvell.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:58484 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbaEVMVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 08:21:12 -0400
Received: by mail-la0-f47.google.com with SMTP id pn19so2536946lab.6
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 05:21:11 -0700 (PDT)
In-Reply-To: <1400742346-24727-1-git-send-email-huizhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-05-2014 11:05, huizhang wrote:

> From: Hui Zhang <huizhang@marvell.com>

>      Bug report on https://bugzilla.kernel.org/show_bug.cgi?id=75781
>
>      When a local output ipsec packet match the mangle table rule,
>      and be set mark value, the packet will be route again in
>      route_me_harder -> _session_decoder6

>      In this case, the nhoff in CB of skb was still the default
>      value 0. So the protocal match can't success and the packet can't match
>      correct SA rule,and then the packet be send out in plaintext.

>      To fixed up the issue. The CB->nhoff must be set.

> Signed-off-by: huizhang <huizhang@marvell.com>

    Why not Hui Zhang, like in the From field?

> ---
>   net/ipv6/xfrm6_policy.c |    2 ++
>   1 file changed, 2 insertions(+)

> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index 5f8e128..869b68b 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -134,6 +134,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
>   	const struct ipv6hdr *hdr = ipv6_hdr(skb);
>   	struct ipv6_opt_hdr *exthdr;
>   	const unsigned char *nh = skb_network_header(skb);
> +	if(IP6CB(skb)->nhoff==0)

    Please, surround == with a space on each side.

WBR, Sergei
