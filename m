From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next v3 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 24 Feb 2014 22:57:24 +0300
Message-ID: <530BA424.8070007@cogentembedded.com>
References: <1393244920-15903-1-git-send-email-sw@simonwunderlich.de> <1393244920-15903-4-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de
To: Simon Wunderlich <sw@simonwunderlich.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:50890 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbaBXS52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 13:57:28 -0500
Received: by mail-la0-f46.google.com with SMTP id hr17so399560lab.19
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 10:57:27 -0800 (PST)
In-Reply-To: <1393244920-15903-4-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/24/2014 03:28 PM, Simon Wunderlich wrote:

> MPLS labels may contain traffic control information, which should be
> evaluated and used by the wireless subsystem if present.

> Also check for IEEE 802.21 which is always network control traffic.

> Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
> Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
> ---
> Changes to second version:

>   * rely on skb->protocol instead of checking ethertype

> Changes to first version:
>
>   * include linux/mpls.h, not the UAPI one
>   * change __constant_htons to htons
> ---
>   net/wireless/util.c |   16 ++++++++++++++++
>   1 file changed, 16 insertions(+)

> diff --git a/net/wireless/util.c b/net/wireless/util.c
> index d39c371..6799d5a 100644
> --- a/net/wireless/util.c
> +++ b/net/wireless/util.c
[...]
> @@ -717,6 +718,21 @@ unsigned int cfg80211_classify8021d(struct sk_buff *skb,
>   	case htons(ETH_P_IPV6):
>   		dscp = ipv6_get_dsfield(ipv6_hdr(skb)) & 0xfc;
>   		break;
> +	case htons(ETH_P_MPLS_UC):
> +	case htons(ETH_P_MPLS_MC): {
> +		struct mpls_label_stack mpls_tmp, *mpls;
> +
> +		mpls = skb_header_pointer(skb, sizeof(struct ethhdr),
> +					  sizeof(*mpls), &mpls_tmp);
> +		if (!mpls)
> +			return 0;
> +
> +		return (ntohl(mpls->entry) & MPLS_LS_TC_MASK)
> +			>> MPLS_LS_TC_SHIFT;
> +		}

    Brace is over-indented here, it can't be at the same level as the 
statements it embraces.

WBR, Sergei
