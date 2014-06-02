From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/2] sfc: use 64-bit writes for PIO.
Date: Sun, 01 Jun 2014 22:25:34 -0700 (PDT)
Message-ID: <20140601.222534.1375636710740653884.davem@davemloft.net>
References: <53870984.6020803@solarflare.com>
	<538709E6.7080108@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaFBFZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 01:25:35 -0400
In-Reply-To: <538709E6.7080108@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Thu, 29 May 2014 11:20:22 +0100

> +/* Copy in explicit 64-bit writes. */
> +static void efx_memcpy_64(void *dest, void *src, size_t len)
> +{
> +	uint64_t *src64 = src, *dest64 = dest;
> +	size_t i, l64 = len / 8;
> +
> +	WARN_ON_ONCE(len % 8 != 0);
> +	WARN_ON_ONCE(((u8 *)dest - (u8 *)0) % 8 != 0);
> +	BUILD_BUG_ON(sizeof(uint64_t) != 8);
> +
> +	for(i = 0; i < l64; ++i)
> +		dest64[i] = src64[i];
> +}

You absolutely, positively, cannot do this.

I/O memory pointers aren't pointers, they are opaque addresses, sparse
should have given you a loud warning about this.

On some platforms they are physical addresses, or some other special
value.

Therefore you cannot directly dereference them.

You _must_ use the io.h accessors.
