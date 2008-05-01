From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] unify the macro get_u16 in the file tulip.h
Date: Wed, 30 Apr 2008 18:15:22 -0600
Message-ID: <20080501001522.GB10542@colo.lackof.org>
References: <93C271C5-550E-406B-AE43-C83419EA0BC6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>, netdev@vger.kernel.org,
	gao changli <xiaosuo@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:55492 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753331AbYEAAPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 20:15:34 -0400
Content-Disposition: inline
In-Reply-To: <93C271C5-550E-406B-AE43-C83419EA0BC6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 01:34:38AM +0800, gao changli wrote:
> Unify the macro get_u16 with le16_to_cpu.
>
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

Jeff,
please apply.  Depends on other patches that define le16_to_cpu().

grant

> ---
>
>  tulip.h |    6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
>
> --- linux/drivers/net/tulip/tulip.h	2008-04-30 23:25:24.000000000 +0800
> +++ linux-new/drivers/net/tulip/tulip.h	2008-04-30 23:28:04.000000000 +0800
> @@ -299,11 +299,7 @@
>
>  #define RUN_AT(x) (jiffies + (x))
>
> -#if defined(__i386__)			/* AKA get_unaligned() */
> -#define get_u16(ptr) (*(u16 *)(ptr))
> -#else
> -#define get_u16(ptr) (((u8*)(ptr))[0] + (((u8*)(ptr))[1]<<8))
> -#endif
> +#define get_u16(ptr) le16_to_cpu(*(u16*)(ptr))
>
>  struct medialeaf {
>  	u8 type;
