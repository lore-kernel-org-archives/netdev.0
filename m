From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/3] Export cdc_ncm_{tx,rx}_fixup functions
Date: Wed, 03 Jul 2013 09:43:49 +0200
Message-ID: <87a9m4w0ju.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	<87wqp9xja5.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	<alpine.LNX.2.02.1307022202570.26010@eeeadesso>
	<alpine.LNX.2.02.1307022207060.26010@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51752 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960Ab3GCHnx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 03:43:53 -0400
In-Reply-To: <alpine.LNX.2.02.1307022207060.26010@eeeadesso> (Enrico Mioso's
	message of "Tue, 2 Jul 2013 22:10:27 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Exports those functions to be able to re-use them in other drivers if=
 needed.
>
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 493277e..22ed51c 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -885,6 +885,8 @@ error:
> =20
>  	return NULL;
>  }
> +EXPORT_SYMBOL_GPL(cdc_ncm_tx_fixup);
> +
> =20

Don't add spurious empty lines.



>  /* verify NTB header and return offset of first NDP, or negative err=
or */
>  int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff =
*skb_in)
> @@ -1040,6 +1042,7 @@ err_ndp:
>  error:
>  	return 0;
>  }
> +EXPORT_SYMBOL_GPL(cdc_ncm_rx_fixup);
> =20
>  static void
>  cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
> diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.=
h
> index cc25b70..163244b 100644
> --- a/include/linux/usb/cdc_ncm.h
> +++ b/include/linux/usb/cdc_ncm.h
> @@ -133,3 +133,6 @@ extern void cdc_ncm_unbind(struct usbnet *dev, st=
ruct usb_interface *intf);
>  extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx=
, struct sk_buff *skb, __le32 sign);
>  extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct s=
k_buff *skb_in);
>  extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpof=
fset);
> +struct sk_buff *
> +cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flag=
s);

I would have put this on a single line, even if it breaks the 80 charac=
ter limit.

BTW, is breaking that limit more of a problem for you?  I can certainly
understand that you want to strictly obey it if it is..

> +int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in);

Both of these need "export" I believe...


Bj=C3=B8rn
