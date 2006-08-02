From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/23] [PATCH] [XFRM] STATE: Allow non IPsec protocol.
Date: Tue, 01 Aug 2006 17:19:42 -0700 (PDT)
Message-ID: <20060801.171942.111202151.davem@davemloft.net>
References: <1154165440812-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3300
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750854AbWHBATm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:19:42 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <1154165440812-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:40 +0900

>  static inline int xfrm_id_proto_match(u8 proto, u8 userproto)
>  {
> +#ifdef CONFIG_XFRM_ADVANCED
> +	return (!userproto || proto == userproto ||
> +		(userproto == IPSEC_PROTO_ANY && (proto == IPPROTO_AH ||
> +						  proto == IPPROTO_ESP ||
> +						  proto == IPPROTO_COMP)));
> +#else
>  	return (userproto == IPSEC_PROTO_ANY || proto == userproto);
> +#endif
>  }

Now it makes sense.  All the previous patches were hard to
understand without this logic being seen first.

It is another argument for removing XFRM_ADVANCED config option.
