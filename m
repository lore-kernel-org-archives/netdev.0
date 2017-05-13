From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 1/5] dsa: add support for Microchip KSZ tail
 tagging
Date: Sat, 13 May 2017 15:03:26 +0200
Message-ID: <20170513130326.GA14058@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A632AB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        davem@davemloft.net, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57632 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754052AbdEMNDd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 13 May 2017 09:03:33 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A632AB@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 08:07:54PM +0000, Woojung.Huh@microchip.com wrote:
> +	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
> +
> +	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
> +		nskb = skb;
> +	} else {
> +		nskb = alloc_skb(NET_IP_ALIGN + skb->len +
> +				 padlen + KSZ_INGRESS_TAG_LEN, GFP_ATOMIC);

Hi Woojung

Thanks for reusing the existing skb when possible. This should help
with performance.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
