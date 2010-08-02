From: Juuso Oikarinen <juuso.oikarinen-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: wl12xx: do not use kfree'd memory
Date: Mon, 02 Aug 2010 08:04:11 +0300
Message-ID: <1280725451.6475.111.camel@wimaxnb.nmp.nokia.com>
References: <1280594039-3246-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Coelho Luciano (Nokia-MS/Helsinki)" <Luciano.Coelho-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Paasikivi Teemu.3 (EXT-Ixonos/Tampere)"
	<ext-teemu.3.paasikivi-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: ext Kulikov Vasiliy <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1280594039-3246-1-git-send-email-segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-07-31 at 18:33 +0200, ext Kulikov Vasiliy wrote:
> wl1271_dump() uses cmd after kfree(cmd). Move kfree() just after
> wl1271_dump().
> 
> Signed-off-by: Kulikov Vasiliy <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/wl12xx/wl1271_spi.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/wl12xx/wl1271_spi.c b/drivers/net/wireless/wl12xx/wl1271_spi.c
> index 96d25fb..4cb99c5 100644
> --- a/drivers/net/wireless/wl12xx/wl1271_spi.c
> +++ b/drivers/net/wireless/wl12xx/wl1271_spi.c
> @@ -160,9 +160,8 @@ static void wl1271_spi_init(struct wl1271 *wl)
>  	spi_message_add_tail(&t, &m);
>  
>  	spi_sync(wl_to_spi(wl), &m);
> -	kfree(cmd);
> -
>  	wl1271_dump(DEBUG_SPI, "spi init -> ", cmd, WSPI_INIT_CMD_LEN);
> +	kfree(cmd);
>  }
>  
>  #define WL1271_BUSY_WORD_TIMEOUT 1000

Whoops ;) Good catch, thanks.

Acked-by: Juuso Oikarinen <juuso.oikarinen-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

-Juuso

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
