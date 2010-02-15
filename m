From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark infrastructure
Date: Mon, 15 Feb 2010 16:42:40 +0100
Message-ID: <4B796B70.2050102@trash.net>
References: <xfrm-mark-net-next> <1266160732-946-1-git-send-email-hadi@cyberus.ca> <1266160732-946-2-git-send-email-hadi@cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63265 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755689Ab0BOPmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 10:42:43 -0500
In-Reply-To: <1266160732-946-2-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> +static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_kmark *m)
> +{
> +	if (attrs[XFRMA_MARK])
> +		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
> +	else
> +		m->v = m->m = 0;
> +
> +	return m->v & m->m;
> +}
> +
> +static inline int xfrm_mark_put(struct sk_buff *skb, struct xfrm_kmark *m)
> +{
> +	if (m->m & m->v)
> +		NLA_PUT(skb, XFRMA_MARK, sizeof(struct xfrm_kmark), m);

This doesn't look right. A mark value of 0 with a mask of ~0 won't
be properly dumped. I think this should check for (m->m | m->v).

> +	return 0;
> +
> +nla_put_failure:
> +	return -1;
> +}
> +
>  #endif	/* _NET_XFRM_H */

