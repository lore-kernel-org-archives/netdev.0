From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v5] sfc: PIO:Restrict to 64bit arch and use 64-bit
 writes.
Date: Tue, 10 Jun 2014 23:32:00 -0700 (PDT)
Message-ID: <20140610.233200.1652605957870754730.davem@davemloft.net>
References: <53920741.4060704@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbaFKGcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 02:32:04 -0400
In-Reply-To: <53920741.4060704@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 6 Jun 2014 19:24:01 +0100

> +/* Hardware issue requires that only 64-bit naturally aligned writes
> + * are seen by hardware.
> + */
> +#if BITS_PER_LONG == 64
> +/* not strictly necessary to restrict to x86 arch, but done for safety
> + * since unusual write combining behaviour can break PIO.
> + */
> +#ifdef CONFIG_X86_64
>  /* PIO is a win only if write-combining is possible */
>  #ifdef ARCH_HAS_IOREMAP_WC
>  #define EFX_USE_PIO 1
>  #endif
> +#endif
> +#endif

Just restrict this plainly to X86_64, the 64-bit test is completely
redundant.  It's obvious that x86_64 is the only platform you care
about and plan on testing or caring about in any way, so just make
that explicit.

I'm sorry about giving you continually a hard time about this, but
this is really gross, platform specific, ugly hackery going on here
and I'm going to do whatever I can to minimize it's uglyness.

Thank you.
