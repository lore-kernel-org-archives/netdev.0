From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5 2.6.21-rc7] l2tp: pppol2tp changes to existing ppp
 kernel headers
Date: Mon, 30 Apr 2007 00:08:49 -0700 (PDT)
Message-ID: <20070430.000849.55725376.davem@davemloft.net>
References: <200704231601.l3NG13hW030163@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423098AbXD3HIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:08:52 -0400
In-Reply-To: <200704231601.l3NG13hW030163@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 23 Apr 2007 17:01:03 +0100

> Index: linux-2.6.21-rc7/include/linux/if_pppox.h
> ===================================================================
> --- linux-2.6.21-rc7.orig/include/linux/if_pppox.h
> +++ linux-2.6.21-rc7/include/linux/if_pppox.h
> @@ -18,7 +18,19 @@
>  
>  
>  #include <asm/types.h>
> +#ifdef __KERNEL__
>  #include <asm/byteorder.h>
> +#else
> +#include <endian.h>
> +#include <byteswap.h>
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
> +#define __LITTLE_ENDIAN_BITFIELD
> +#elif __BYTE_ORDER == __BIG_ENDIAN
> +#define __BIG_ENDIAN_BITFIELD
> +#else
> +#error "Adjust your <endian.h> defines."
> +#endif
> +#endif

Please don't do this, doubly especially without a changelog comment
explaining why.

No other kernel header has to accomodate userland issues like this, so
please find another way that doesn't involve crapping up the in-kernel
header files.

Thanks.
