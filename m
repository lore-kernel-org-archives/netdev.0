From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark
 infrastructure
Date: Sun, 21 Feb 2010 22:26:12 -0800 (PST)
Message-ID: <20100221.222612.112587589.davem@davemloft.net>
References: <xfrm-mark-take2>
	<1266699340-5590-1-git-send-email-hadi@cyberus.ca>
	<1266699340-5590-2-git-send-email-hadi@cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51260
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab0BVGZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 01:25:55 -0500
In-Reply-To: <1266699340-5590-2-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sat, 20 Feb 2010 15:55:34 -0500

>  	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
> +	XFRMA_MARK,		/* u32 */
>  	__XFRMA_MAX
>  

XFRM_MARK is "struct xfrm_*mask" not "u32".

> +struct xfrm_kmark {
> +	u32           v; /* value */
> +	u32           m; /* mask */
> +};
> +

You absolutely don't need this song and dance.

If the userspace attribute type equals the kernel one, you can just
define one "struct xfrm_mark" in linux/xfrm.h and use it universally.

This is how we handle this with other XFRM userspace visible
datastructures.

We only make seperate internal ones when they have to be different for
some reason, which is not true here.

Please respin your entire patch set once you've fixed this.

Thanks.
