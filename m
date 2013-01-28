From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Mon, 28 Jan 2013 18:28:13 +0000
Message-ID: <1359397693.2721.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jesse@nicira.com>,
	<eric.dumazet@gmail.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22874 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab3A1S2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 13:28:16 -0500
In-Reply-To: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 14:16 -0800, Pravin B Shelar wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Fixed according to comments from Jesse and Eric.
>  - Factored a MAC layer handler out of skb_gso_segment().
>  - Eliminated copy operation from gre_gso_segment().
>  - Refresh header pointer after pskb_may_pull().
[...]
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -307,6 +307,8 @@ enum {
>  	SKB_GSO_TCPV6 = 1 << 4,
>  
>  	SKB_GSO_FCOE = 1 << 5,
> +
> +	SKB_GSO_GRE = 1 << 6,
>  };
>  
>  #if BITS_PER_LONG > 32
[...]

I think each new GSO flag must have a corresponding net device feature
flag.  In that case you'll need to replace NETIF_F_GSO_RESERVED1 in
include/linux/netdev_features.h and add a name for the feature in
net/core/ethtool.c.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
