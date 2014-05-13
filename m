From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net-next 01/11] net: cdc_ncm: split out rx_max/tx_max
 update of setup
Date: Tue, 13 May 2014 10:09:06 +0200
Message-ID: <1399968546.8278.2.camel@linux-fkkt.site>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
	 <1399736509-1159-2-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47681 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759080AbaEMIJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 04:09:08 -0400
In-Reply-To: <1399736509-1159-2-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-05-10 at 17:41 +0200, Bj=C3=B8rn Mork wrote:
> Split out the part of setup dealing with updating the rx_max
> and tx_max buffer sizes so that this code can be reused for
> dynamically updating the limits.
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
>  drivers/net/usb/cdc_ncm.c | 81 +++++++++++++++++++++++++++++--------=
----------
>  1 file changed, 50 insertions(+), 31 deletions(-)
>=20
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 549dbac710ed..87a32edf7ea5 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -65,6 +65,54 @@ static void cdc_ncm_tx_timeout_start(struct cdc_nc=
m_ctx *ctx);
>  static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_t=
imer);
>  static struct usb_driver cdc_ncm_driver;
> =20
> +/* handle rx_max and tx_max changes */
> +static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, =
u32 new_tx)
> +{
> +	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
> +	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber=
;
> +	u32 val, max, min;
> +
> +	/* clamp new_rx to sane values */
> +	min =3D min_t(u32, USB_CDC_NCM_NTB_MIN_IN_SIZE, le32_to_cpu(ctx->nc=
m_parm.dwNtbInMaxSize));
> +	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_pa=
rm.dwNtbInMaxSize));

Are you sure this makes sense? min_t both times?

	Regards
		Oliver
