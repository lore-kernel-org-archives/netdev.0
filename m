From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.12-rc1-mm1] net/ethernet/eth.c - eth_header
Date: Wed, 23 Mar 2005 15:50:25 -0500
Message-ID: <4241D691.5000707@pobox.com>
References: <200503231734.59277.vicente.feito@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Vicente Feito <vicente.feito@gmail.com>
In-Reply-To: <200503231734.59277.vicente.feito@gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vicente Feito wrote:
> Hi,
> Please consider applying (or droping).
> Thank you.
> 
> Description: This patch prevent drivers from calling eth_header with a 802.3
> frame using a len>1536. In such a case returns -EINVAL, which was hard to
> choose because the ETH_HLEN is supposed to return.
> 
> Signed-off-by: Vicente Feito <vicente.feito@gmail.com>
> 
> 
> ------------------------------------------------------------------------
> 
> --- linux-2.6.12-rc1-mm1/net/ethernet/eth.c.orig	2005-03-22 12:49:08.000000000 +0000
> +++ linux-2.6.12-rc1-mm1/net/ethernet/eth.c	2005-03-22 12:49:36.000000000 +0000
> @@ -78,6 +78,8 @@ int eth_header(struct sk_buff *skb, stru
>  {
>  	struct ethhdr *eth = (struct ethhdr *)skb_push(skb,ETH_HLEN);
>  
> +	if (type == ETH_P_802_3 && len >= 1536)
> +		return -EINVAL;

Why?  Won't this break for jumbo frames?

	Jeff
