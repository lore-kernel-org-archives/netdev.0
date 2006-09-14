From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH] bridge: add ETH_HLEN to packet_length
Date: Thu, 14 Sep 2006 23:53:48 +0300
Message-ID: <4509C15C.6080308@kolumbus.fi>
References: <20060914182751.GA15203@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1.turkuamk.fi ([195.148.208.125]:21190 "EHLO
	mail-gw1.turkuamk.fi") by vger.kernel.org with ESMTP
	id S1751052AbWINUwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 16:52:08 -0400
To: Jon Mason <jdmason@kudzu.us>
In-Reply-To: <20060914182751.GA15203@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Mason wrote:
> In br_dev_queue_push_xmit, why is the check to drop mtu oversized
> packets not checking for enough room for the impending ETH_HLEN size
> skb_push?  In some code currently under development, we are seeing
> skb_under_panic being called from the "skb_push(skb, ETH_HLEN)" in that
> code.  It seems to me it would be better to drop those skbs than panic.
> Attached is a patch to do this.
>
> Thanks,
> Jon
>
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
>
> diff -r b1d36669f98d net/bridge/br_forward.c
> --- a/net/bridge/br_forward.c	Mon Sep  4 03:00:04 2006 +0000
> +++ b/net/bridge/br_forward.c	Thu Sep 14 13:18:04 2006 -0500
> @@ -29,7 +29,8 @@ static inline int should_deliver(const s
>  
>  static inline unsigned packet_length(const struct sk_buff *skb)
>  {
> -	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
> +	return skb->len - ETH_HLEN - 
> +		(skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
>  }
>
>   
packet_length() is a wrong place to do that, mtu has nothing to do with 
skb headroom.

--Mika

