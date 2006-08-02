From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/23] [PATCH] [XFRM] STATE: Search by address using
 source address list.
Date: Tue, 01 Aug 2006 17:06:18 -0700 (PDT)
Message-ID: <20060801.170618.75430766.davem@davemloft.net>
References: <11541654182334-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44424
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750771AbWHBAGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:06:18 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <11541654182334-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:18 +0900

> +#ifdef CONFIG_XFRM_ADVANCED
> +	struct xfrm_state	*(*state_lookup_byaddr)(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto);
> +#endif

I think we should delete XFRM_ADVANCED config option, it is only
serving to make the code very ugly and full of ifdefs.

> +#ifdef CONFIG_XFRM_ADVANCED
> +	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
> +#else
> +	int use_spi = 1;
> +#endif

Why this transformation?  In fact, you added several others.
xfrm_id_proto_match() with userproto argument IPSEC_PROTO_ANY
always evaluates to one.

If you intend to change the userproto argument in some future
changeset, then add the xfrm_id_proto_match() call in that
changeset.
