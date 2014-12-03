From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/4] vlan: Fix mac_len adjustment.
Date: Wed, 3 Dec 2014 15:32:41 +0100
Message-ID: <20141203153241.5866bb75@griffin>
References: <1417473038-2165-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752139AbaLCOcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 09:32:46 -0500
In-Reply-To: <1417473038-2165-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  1 Dec 2014 14:30:38 -0800, Pravin B Shelar wrote:
> skb_reset_mac_len() sets length according to ethernet and network
> offsets, but mpls expects mac-length to be offset to mpls header (ref.
> skb_mpls_header()). Therefore rather than reset we need to subtract
> VLAN_HLEN from mac_len.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/core/skbuff.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 92116df..c45888f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4178,7 +4178,7 @@ static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
>  	if (skb_network_offset(skb) < ETH_HLEN)
>  		skb_set_network_header(skb, ETH_HLEN);
>  
> -	skb_reset_mac_len(skb);
> +	skb->mac_len -= VLAN_HLEN;
>  pull:
>  	__skb_pull(skb, offset);
>  

See my previous explanation why this patch is wrong with the current
code: http://article.gmane.org/gmane.linux.network/339457

 Jiri

-- 
Jiri Benc
