From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Wed, 9 Nov 2016 17:10:18 +0100
Message-ID: <20161109171018.69d08ff9@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-3-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55820 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754144AbcKIQK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:10:26 -0500
In-Reply-To: <1478371557-71888-3-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2016 11:45:52 -0700, Pravin B Shelar wrote:
> @@ -2058,7 +2059,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
>  				      vni, md, flags, udp_sum);
>  		if (err < 0)
> -			goto xmit_tx_error;
> +			goto tx_error;

Seems you're leaking rt here?

> @@ -2117,11 +2118,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		skb_scrub_packet(skb, xnet);
>  		err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
>  				      vni, md, flags, udp_sum);
> -		if (err < 0) {
> -			dst_release(ndst);
> -			dev->stats.tx_errors++;
> -			return;
> -		}
> +		if (err < 0)
> +			goto tx_error;

And ndst here?

 Jiri
