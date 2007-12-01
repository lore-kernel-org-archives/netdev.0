From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] LIB82596: correct data types for hardware addresses
Date: Sat, 01 Dec 2007 16:43:02 -0500
Message-ID: <4751D566.7070703@pobox.com>
References: <20071130221316.3CDBEC2EAD@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44052 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbXLAVnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:43:06 -0500
In-Reply-To: <20071130221316.3CDBEC2EAD@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Bogendoerfer wrote:
> dma_addr_t is 64bit wide on some architectures (for example 64bit MIPS),
> so it's not a good idea to use it for 32bit wide addresses in descriptors.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> ---
> 
>  drivers/net/lib82596.c |   50 ++++++++++++++++++++++++------------------------
>  1 files changed, 25 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
> index 9a855e5..b59f442 100644
> --- a/drivers/net/lib82596.c
> +++ b/drivers/net/lib82596.c
> @@ -176,8 +176,8 @@ struct i596_reg {
>  struct i596_tbd {
>  	unsigned short size;
>  	unsigned short pad;
> -	dma_addr_t     next;
> -	dma_addr_t     data;
> +	u32            next;
> +	u32            data;
>  	u32 cache_pad[5];		/* Total 32 bytes... */
>  };

applied, though its incomplete for today's drivers.  I recommend 
converting those data types to the "sparse" data types that indicate 
endian-ness (see __le32, etc.).  Then verify that the code passes all 
sparse checks.

See Documentation/sparse.txt for more info.

Also, make sure it passes scripts/checkpatch.pl checks too, while you're 
at it...

Thanks,

	Jeff



