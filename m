From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH 3/3] ipgre: capture inner headers during
 encapsulation
Date: Sun, 11 Nov 2012 17:18:30 +0200
Message-ID: <1352647110.5201.4.camel@lb-tlvb-dmitry.il.broadcom.com>
References: <1352427483-4380-1-git-send-email-joseph.gasparakis@intel.com>
 <1352427483-4380-4-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
To: "Joseph Gasparakis" <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352427483-4380-4-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-11-08 at 18:18 -0800, Joseph Gasparakis wrote:
>  
>  	if (skb->ip_summed == CHECKSUM_PARTIAL &&
>  	    skb_checksum_help(skb))
> @@ -902,6 +903,17 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  			tunnel->err_count = 0;
>  	}
>  
> +	offset = skb->data - skb->head;
> +
> +	skb_reset_inner_mac_header(skb);
> +
> +	if (skb->network_header)
> +		skb_set_inner_network_header(skb, skb->network_header - offset);
> +
> +	if (skb->transport_header)
> +		skb_set_inner_transport_header(skb, skb->transport_header -
> +					       offset);
> +
>  	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->dst.header_len;
>  
>  	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||

How it will be useful if skb_checksum_help(skb) will calculate csum? And
leaves nothing to offload 
