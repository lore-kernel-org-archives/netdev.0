From: Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] net: wireless/ath: Fix compile error seen with W=1
Date: Mon, 28 Jan 2013 12:55:37 +0200
Message-ID: <1368762.AOqRHlT7Ra@lx-vladimir>
References: <1359253568-15762-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359253568-15762-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday, January 26, 2013 06:26:08 PM Guenter Roeck wrote:
> make W=3D1 for x86_64 fails with
>=20
> drivers/net/wireless/ath/wil6210/txrx.c: In function =E2=80=98wil_rx_=
fini=E2=80=99:
> drivers/net/wireless/ath/wil6210/txrx.c:550:7: error: variable =E2=80=
=98rc=E2=80=99 set but not
> used [-Werror=3Dunused-but-set-variable]
>=20
> Fix by dropping the variable.
>=20
> Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
> ---
>  drivers/net/wireless/ath/wil6210/txrx.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ath/wil6210/txrx.c b/drivers/net/wi=
reless/ath/wil6210/txrx.c
> index f29c294..b6e8042 100644
> --- a/drivers/net/wireless/ath/wil6210/txrx.c
> +++ b/drivers/net/wireless/ath/wil6210/txrx.c
> @@ -547,7 +547,6 @@ void wil_rx_fini(struct wil6210_priv *wil)
>  	struct vring *vring =3D &wil->vring_rx;
> =20
>  	if (vring->va) {
> -		int rc;
>  		struct wmi_cfg_rx_chain_cmd cmd =3D {
>  			.action =3D cpu_to_le32(WMI_RX_CHAIN_DEL),
>  			.rx_sw_ring =3D {
> @@ -559,7 +558,7 @@ void wil_rx_fini(struct wil6210_priv *wil)
>  			struct wmi_cfg_rx_chain_done_event cfg;
>  		} __packed wmi_rx_cfg_reply;
> =20
> -		rc =3D wmi_call(wil, WMI_CFG_RX_CHAIN_CMDID, &cmd, sizeof(cmd),
> +		(void)wmi_call(wil, WMI_CFG_RX_CHAIN_CMDID, &cmd, sizeof(cmd),
>  			      WMI_CFG_RX_CHAIN_DONE_EVENTID,
>  			      &wmi_rx_cfg_reply, sizeof(wmi_rx_cfg_reply),
>  			      100);
>=20

Thanks for finding it.

I will send series of new patches shortly. This will include changes in
rx chain initialization that, among other, remove fragment you fixed.
Reason is firmware API changes.

Thanks, Vladimir
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
