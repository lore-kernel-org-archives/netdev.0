From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH net-next 1/3] net:use help function of skb_checksum_start_offset
 to calculate offset
Date: Mon, 2 May 2011 18:20:01 -0400
Message-ID: <4DBF2E11.3010904@tilera.com>
References: <4DB1617D.30600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.75]:37972 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757009Ab1EBWZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 18:25:25 -0400
In-Reply-To: <4DB1617D.30600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/2011 7:07 AM, Shan Wei wrote:
> Although these are equivalent, but the skb_checksum_start_offset() is more readable.
>
>
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  drivers/net/tile/tilepro.c |    2 +-
>  net/ipv6/udp.c             |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/tile/tilepro.c b/drivers/net/tile/tilepro.c
> index 0825db6..1e980fd 100644
> --- a/drivers/net/tile/tilepro.c
> +++ b/drivers/net/tile/tilepro.c
> @@ -1930,7 +1930,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
>  	unsigned int len = skb->len;
>  	unsigned char *data = skb->data;
>  
> -	unsigned int csum_start = skb->csum_start - skb_headroom(skb);
> +	unsigned int csum_start = skb_checksum_start_offset(skb);
>  
>  	lepp_frag_t frags[LEPP_MAX_FRAGS];
>  
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 15c3774..95c62a1 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -1328,7 +1328,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u32 features)
>  	/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
>  	 * do checksum of UDP packets sent as multiple IP fragments.
>  	 */
> -	offset = skb->csum_start - skb_headroom(skb);
> +	offset = skb_checksum_start_offset(skb);
>  	csum = skb_checksum(skb, offset, skb->len- offset, 0);
>  	offset += skb->csum_offset;
>  	*(__sum16 *)(skb->data + offset) = csum_fold(csum);

I took the drivers/net/tile/ change into my tree, but I'll defer to David
or some other net person to take the net/ipv6/udp.c change.  Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com


