From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/23] [PATCH] [XFRM] STATE: Add a hook to find where to
 be inserted header in outbound.
Date: Tue, 01 Aug 2006 17:09:16 -0700 (PDT)
Message-ID: <20060801.170916.21925105.davem@davemloft.net>
References: <11541654231584-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53713
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750786AbWHBAJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:09:18 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <11541654231584-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:23 +0900

> @@ -270,6 +270,7 @@ struct xfrm_type
>  	void			(*destructor)(struct xfrm_state *);
>  	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
>  	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
> +	int			(*place_find)(struct xfrm_state *, struct sk_buff *, u8 **);
>  	/* Estimate maximal size of result of transformation of a dgram */
>  	u32			(*get_max_size)(struct xfrm_state *, int size);
>  };

I see a dangerous pattern of adding many, many, many methods
to the xfrm_type structure which are only used by ipv6.
But I cannot suggest another method.

There are frequent calls of the form:

	if (x->type->op != NULL)
		x->type->op(x, y, z);
	else
		foo(y, z);

it might be nicer to hide all of this behind carefully crafted
inline functions.
