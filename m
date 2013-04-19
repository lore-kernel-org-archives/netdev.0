From: hayeswang <hayeswang@realtek.com>
Subject: RE: rtl8168e-vl dropping tftp ack
Date: Fri, 19 Apr 2013 11:27:11 +0800
Message-ID: <DFF62ECF5DF14C65A71A35581D58FFA9@realtek.com.tw>
References: <516EB23B.3080504@canonical.com> <20130417213251.GA13790@electric-eye.fr.zoreil.com> <516FC218.3060002@canonical.com> <20130418215501.GB8944@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'Stefan Bader' <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:44743 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967885Ab3DSD1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 23:27:13 -0400
In-Reply-To: <20130418215501.GB8944@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Friday, April 19, 2013 5:55 AM
> To: Stefan Bader
> Cc: netdev@vger.kernel.org; nic_swsd
> Subject: Re: rtl8168e-vl dropping tftp ack
> 
[...]
> +		if (unlikely(skb->len < ETH_ZLEN &&
> +		    (tp->mac_version == RTL_GIGA_MAC_VER_34))) {
> +			if (skb_padto(skb, ETH_ZLEN))
> +				return false;
> +			skb_checksum_help(skb);
> +			skb_put(skb, ETH_ZLEN - skb->len);
> +			return true;
> +		}
> +

I don't think the hw checksum is enabled, because there are many successful
small packets before the failure. However, I also want to know if any skb->len <
60 occurs, so I think the checking should be included by the other case.
 
Best Regards,
Hayes
