From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH][RESEND 3] IPv6: 6rd tunnel mode
Date: Tue, 22 Sep 2009 16:06:48 -0700
Message-ID: <1253660808.30020.131.camel@Joe-Laptop.home>
References: <20090922220251.GA22874@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexandre Cassen <acassen@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1132 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbZIVXGp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2009 19:06:45 -0400
In-Reply-To: <20090922220251.GA22874@lnxos.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-23 at 00:02 +0200, Alexandre Cassen wrote:
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 0ae4f64..3587149 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
[]
> +static inline __be32 try_6rd(struct in6_addr *addr, u8 prefix_len, struct in6_addr *v6dst)
> +{
> +	__be32 dst = 0;
> +
> +	/* isolate addr according to mask */
> +	if (ipv6_prefix_equal(v6dst, addr, prefix_len)) {
> +		unsigned int d32_off, bits;
> +
> +		d32_off = prefix_len >> 5;
> +		bits = (prefix_len & 0x1f);
> +
> +		dst = (ntohl(v6dst->s6_addr32[d32_off]) << bits);

unnecessary parens and a sparse warning?
Perhaps use a temporary u32 and an htonl or cpu_to_be32 at the end?

> +		if (bits)
> +			dst |= ntohl(v6dst->s6_addr32[d32_off + 1]) >> (32 - bits);
> +		dst = htonl(dst);
> +	}
> +	return dst;
> +}
> +#endif


