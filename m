From: "Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmsmac: initialize morepending in brcms_b_recv()
Date: Sun, 23 Dec 2012 18:31:13 +0100
Message-ID: <50D73FE1.6080907@broadcom.com>
References: <1356210434-28435-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Piotr Haber" <phaber-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Geert Uytterhoeven" <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1356210434-28435-1-git-send-email-geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/22/2012 10:07 PM, Geert Uytterhoeven wrote:
> drivers/net/wireless/brcm80211/brcmsmac/main.c: In function =E2=80=98=
brcms_b_recv=E2=80=99:
> drivers/net/wireless/brcm80211/brcmsmac/main.c:7636: warning: =E2=80=98=
morepending=E2=80=99 may be used uninitialized in this function
>=20

Reading the code this warning seems to be invalid except when RXBND is
defined as zero, which would make the whole function totally bogus.
Would be good to have a WARN_ON(!RXBND) in brcms_b_attach().

I don't like pleasing a compiler with unnecessary initializers but I am
also for builds with zero warnings. So...

Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
> ---
>  drivers/net/wireless/brcm80211/brcmsmac/main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers=
/net/wireless/brcm80211/brcmsmac/main.c
> index 17594de..5f0f444 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
> @@ -7633,7 +7633,7 @@ brcms_b_recv(struct brcms_hardware *wlc_hw, uin=
t fifo, bool bound)
> =20
>  	uint n =3D 0;
>  	uint bound_limit =3D bound ? RXBND : -1;
> -	bool morepending;
> +	bool morepending =3D false;
> =20
>  	skb_queue_head_init(&recv_frames);
> =20


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
