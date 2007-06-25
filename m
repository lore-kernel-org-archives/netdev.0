From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [NET] au1000_eth: Fix warnings.
Date: Mon, 25 Jun 2007 16:02:16 -0700
Message-ID: <20070625160216.e9e29d7f.akpm@linux-foundation.org>
References: <20070624135953.GA16754@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48672 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751334AbXFYXDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 19:03:03 -0400
In-Reply-To: <20070624135953.GA16754@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 Jun 2007 15:59:54 +0200
Ralf Baechle <ralf@linux-mips.org> wrote:

> Fixed by including <linux/dma-mapping.h>:
> 
>   CC      drivers/net/au1000_eth.o
> drivers/net/au1000_eth.c: In function 'au1000_probe':
> drivers/net/au1000_eth.c:661: warning: implicit declaration of function 'dma_alloc_noncoherent'
> drivers/net/au1000_eth.c:802: warning: implicit declaration of function 'dma_free_noncoherent'
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index c39ab80..c27cfce 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -34,7 +34,7 @@
>   *
>   *
>   */
> -
> +#include <linux/dma-mapping.h>
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/string.h>

That's more than a warning fix.  On most platforms, dma_alloc_noncoherent()
is a #define so the driver just won't link there.

<looks>

But the driver is mips-only, and MIPS uses a regular C function for
dma_alloc_noncoherent(), so you got lucky.

Still, I'd say this is for-2.6.22.
