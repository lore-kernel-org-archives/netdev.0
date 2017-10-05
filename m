From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH] ipv6: gso: fix payload length when gso_size is zero
Date: Thu, 5 Oct 2017 11:24:15 -0700
Message-ID: <44d05220-0bab-4dfd-09e0-8a1a37d10ce8@oracle.com>
References: <1507223207-17557-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Miller <davem@davemloft.net>
To: Alexey Kodanev <alexey.kodanev@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26251 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdJESYm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 14:24:42 -0400
In-Reply-To: <1507223207-17557-1-git-send-email-alexey.kodanev@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/17 10:06 AM, Alexey Kodanev wrote:
> When gso_size reset to zero for the tail segment in skb_segment(), later
> in ipv6_gso_segment(), we will get incorrect payload_len for that segment.
> inet_gso_segment() already has a check for gso_size before calculating
> payload so fixing only IPv6 part.
> 
> The issue was found with LTP vxlan & gre tests over ixgbe NIC.
> 
> Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---
>   net/ipv6/ip6_offload.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index cdb3728..4a87f94 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -105,7 +105,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>   
>   	for (skb = segs; skb; skb = skb->next) {
>   		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
> -		if (gso_partial)
> +		if (gso_partial && skb_is_gso(skb))
>   			payload_len = skb_shinfo(skb)->gso_size +
>   				      SKB_GSO_CB(skb)->data_offset +
>   				      skb->head - (unsigned char *)(ipv6h + 1);
> 

Reviewed-by: Girish Moodalbail <girish.moodalbail@oracle.com>
