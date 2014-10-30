From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net] gre: Use inner mac length when computing tunnel length
Date: Thu, 30 Oct 2014 08:52:41 -0700
Message-ID: <54525EC9.8060702@redhat.com>
References: <1414683656-26493-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	alexander.duyck@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759890AbaJ3Pwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 11:52:46 -0400
In-Reply-To: <1414683656-26493-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2014 08:40 AM, Tom Herbert wrote:
> Currently, skb_inner_network_header is used but this does not account
> for Ethernet header for ETH_P_TEB. Use skb_inner_mac_header which
> handles TEB and also should work with IP encapsulation in which case
> inner mac and inner network headers are the same.
>
> Tested: Ran TCP_STREAM over GRE, worked as expected.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>   net/ipv4/gre_offload.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index f6e345c..bb5947b 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -47,7 +47,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>
>   	greh = (struct gre_base_hdr *)skb_transport_header(skb);
>
> -	ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
> +	ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
>   	if (unlikely(ghl < sizeof(*greh)))
>   		goto out;
>
>

This works for me.  We probably need to queue this up for stable as well 
since this bug goes back as far as 3.14.

Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
