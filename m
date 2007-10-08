From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] libertas link error due to gcc `smartness'
Date: Mon, 08 Oct 2007 08:56:30 -0400
Message-ID: <1191848190.2703.17.camel@localhost.localdomain>
References: <Pine.LNX.4.64.0710080940110.8127@anakin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <marcelo-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Development <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0710080940110.8127@anakin>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-08 at 09:43 +0200, Geert Uytterhoeven wrote:
> Some versions of gcc replace strstr() calls with a single-character `needle'
> parameter by strchr() behind our back. This causes a link error if strchr() is
> defined as an inline function in <asm/string.h> (e.g. on m68k):
> 
> | drivers/built-in.o: In function `libertas_parse_chan':
> | linux/drivers/net/wireless/libertas/debugfs.c:209: undefined reference to `strchr'
> | drivers/built-in.o: In function `libertas_parse_ssid':
> | linux/drivers/net/wireless/libertas/debugfs.c:260: undefined reference to `strchr'
> 
> Avoid this by explicitly calling strchr() instead.
> 
> Also include <linux/string.h>, because this file calls lots of str*() routines.
> 
> Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>

Acked-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

> ---
> Due to the lack of hardware, I could not test the functionality of this change.
> I was just trying to compile a kernel with a much enabled as possible.
> 
>  drivers/net/wireless/libertas/debugfs.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> --- a/drivers/net/wireless/libertas/debugfs.c
> +++ b/drivers/net/wireless/libertas/debugfs.c
> @@ -3,6 +3,7 @@
>  #include <linux/debugfs.h>
>  #include <linux/delay.h>
>  #include <linux/mm.h>
> +#include <linux/string.h>
>  #include <net/iw_handler.h>
>  
>  #include "dev.h"
> @@ -205,7 +206,7 @@ static int libertas_parse_chan(char *buf
>  	if (!start)
>  		return -EINVAL;
>  	start += 5;
> -	end = strstr(start, " ");
> +	end = strchr(start, ' ');
>  	if (!end)
>  		end = buf + count;
>  	hold = kzalloc((end - start)+1, GFP_KERNEL);
> @@ -256,7 +257,7 @@ static void libertas_parse_ssid(char *bu
>  	if (!hold)
>  		return;
>  	hold += 5;
> -	end = strstr(hold, " ");
> +	end = strchr(hold, ' ');
>  	if (!end)
>  		end = buf + count - 1;
>  
> 
> Gr{oetje,eeting}s,
> 
> 						Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
> 							    -- Linus Torvalds
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
