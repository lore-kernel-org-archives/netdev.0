From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 01/17] drivers/net/mv643xx_eth.c: Use FIELD_SIZEOF
Date: Wed, 26 Mar 2008 00:36:25 -0400
Message-ID: <47E9D2C9.1010006@garzik.org>
References: <200803042319.m24NJK7X002654@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia@diku.dk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34244 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755353AbYCZEg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:36:28 -0400
In-Reply-To: <200803042319.m24NJK7X002654@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Robert P.J. Day proposed to use the macro FIELD_SIZEOF in replace of code
> that matches its definition.
> 
> The modification was made using the following semantic patch
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @haskernel@
> @@
> 
> #include <linux/kernel.h>
> 
> @depends on haskernel@
> type t;
> identifier f;
> @@
> 
> - (sizeof(((t*)0)->f))
> + FIELD_SIZEOF(t, f)
> 
> @depends on haskernel@
> type t;
> identifier f;
> @@
> 
> - sizeof(((t*)0)->f)
> + FIELD_SIZEOF(t, f)
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/mv643xx_eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/mv643xx_eth.c~drivers-net-mv643xx_ethc-use-field_sizeof drivers/net/mv643xx_eth.c
> --- a/drivers/net/mv643xx_eth.c~drivers-net-mv643xx_ethc-use-field_sizeof
> +++ a/drivers/net/mv643xx_eth.c
> @@ -3155,7 +3155,7 @@ struct mv643xx_stats {
>  	int stat_offset;
>  };
>  
> -#define MV643XX_STAT(m) sizeof(((struct mv643xx_private *)0)->m), \
> +#define MV643XX_STAT(m) FIELD_SIZEOF(struct mv643xx_private, m), \
>  					offsetof(struct mv643xx_private, m)
>  
>  static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
> _
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

applied


