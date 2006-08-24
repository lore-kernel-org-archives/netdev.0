From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/44] [IPV6] IPSEC: Support sending with Mobile IPv6
 extension headers.
Date: Wed, 23 Aug 2006 19:31:39 -0700 (PDT)
Message-ID: <20060823.193139.75761052.davem@davemloft.net>
References: <11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663275-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19862
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030212AbWHXCbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:31:37 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:28 +0900

> Mobile IPv6 defines home address option as an option of destination
> options header. It is placed before fragment header then
> ip6_find_1stfragopt() is fixed to know about it.
> Home address option also carries final source address of the flow, then
> outbound AH calculation should take care of it like routing header case.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, and I fixed the leak mentioned here:

> +#ifdef CONFIG_IPV6_MIP6
> +	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len, XFRM_POLICY_IN))
> +		goto out;
> +#else
>  	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len))
>  		goto free_out;
> +#endif

By making MIP6 case goto free_out; too.
