From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net,stable] net: huawei_cdc_ncm: increase command buffer size
Date: Wed, 18 Jun 2014 19:55:50 +0200
Message-ID: <c498d030-8335-482c-aede-66e7bcdfebb0@email.android.com>
References: <1403094084-13588-1-git-send-email-bjorn@mork.no> <1403100197.2266.14.camel@dcbw.local> <alpine.LNX.2.03.1406181831060.596@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>, Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:58277 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbaFRR4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 13:56:03 -0400
In-Reply-To: <alpine.LNX.2.03.1406181831060.596@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No problem. I think Dan's testing is sufficient verification that this =
doesn't have unexpected side effects.


Bj=C3=B8rn

On 18 June 2014 18:32:58 CEST, Enrico Mioso <mrkiko.rs@gmail.com> wrote=
:
>I am sorry - I am not in good conditions to perform the testing. But -
>I think=20
>it sould be fine anyway.
>Sorry Bjorn. I might be able to do it in the weekend if you would like=
=2E
>Enrico
>
>
>On Wed, 18 Jun 2014, Dan Williams wrote:
>
>=3D=3DDate: Wed, 18 Jun 2014 16:03:17
>=3D=3DFrom: Dan Williams <dcbw@redhat.com>
>=3D=3DTo: Bj=C3=B8rn Mork <bjorn@mork.no>
>=3D=3DCc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
>=3D=3D    Enrico Mioso <mrkiko.rs@gmail.com>
>=3D=3DSubject: Re: [PATCH net,
>=3D=3D    stable] net: huawei_cdc_ncm: increase command buffer size
>=3D=3D
>=3D=3DOn Wed, 2014-06-18 at 14:21 +0200, Bj=C3=B8rn Mork wrote:
>=3D=3D> Messages from the modem exceeding 256 bytes cause communicatio=
n
>=3D=3D> failure.
>=3D=3D>=20
>=3D=3D> The WDM protocol is strictly "read on demand", meaning that we=
 only
>=3D=3D> poll for unread data after receiving a notification from the m=
odem.
>=3D=3D> Since we have no way to know how much data the modem has to se=
nd,
>=3D=3D> we must make sure that the buffer we provide is "big enough".
>=3D=3D> Message truncation does not work. Truncated messages are left
>unread
>=3D=3D> until the modem has another message to send.  Which often won'=
t
>=3D=3D> happen until the userspace application has given up waiting fo=
r the
>=3D=3D> final part of the last message, and therefore sends another
>command.
>=3D=3D>=20
>=3D=3D> With a proper CDC WDM function there is a descriptor telling u=
s
>=3D=3D> which buffer size the modem uses. But with this vendor specifi=
c
>=3D=3D> implementation there is no known way to calculate the exact "b=
ig
>=3D=3D> enough" number.  It is an unknown property of the modem firmwa=
re.
>=3D=3D> Experience has shown that 256 is too small.  The discussion of
>=3D=3D> this failure ended up concluding that 512 might be too small a=
s
>=3D=3D> well. So 1024 seems like a reasonable value for now.
>=3D=3D>=20
>=3D=3D> Fixes: 41c47d8cfd68 ("net: huawei_cdc_ncm: Introduce the
>huawei_cdc_ncm driver")
>=3D=3D> Cc: Enrico Mioso <mrkiko.rs@gmail.com>
>=3D=3D> Reported-by: Dan Williams <dcbw@redhat.com>
>=3D=3D> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>=3D=3D
>=3D=3DTested-by: Dan Williams <dcbw@redhat.com>
>=3D=3D
>=3D=3D'<CR><LF>^SYSCFGEX:
>=3D=3D("00","01","02","03","99"),((400380,"GSM900/GSM1800/WCDMA2100"),=
(6a80000,"GSM850/GSM1900/WCDMA850/AWS/WCDMA1900"),(3fffffff,"All
>bands")),(0-2),(0-4),((1081b,"LTE_B1/LTE_B2/LTE_B4/LTE_B5/LTE_B12/LTE_=
B17"),(7fffffffffffffff,"All
>bands"))<CR><LF><CR><LF>OK<CR><LF>'
>=3D=3D
>=3D=3DI get the last "<LF>" now :)
>=3D=3D
>=3D=3D> ---
>=3D=3D>=20
>=3D=3D> The problem is a showstopper for anyone hitting it, so I belie=
ve
>this
>=3D=3D> fix should go into all maintained stable kernels with this dri=
ver.
>=3D=3D> That is anything based on v3.13 or newer.
>=3D=3D>=20
>=3D=3D> Thanks,
>=3D=3D> Bj=C3=B8rn
>=3D=3D>=20
>=3D=3D>=20
>=3D=3D>  drivers/net/usb/huawei_cdc_ncm.c | 7 ++++---
>=3D=3D>  1 file changed, 4 insertions(+), 3 deletions(-)
>=3D=3D>=20
>=3D=3D> diff --git a/drivers/net/usb/huawei_cdc_ncm.c
>b/drivers/net/usb/huawei_cdc_ncm.c
>=3D=3D> index f9822bc75425..5d95a13dbe2a 100644
>=3D=3D> --- a/drivers/net/usb/huawei_cdc_ncm.c
>=3D=3D> +++ b/drivers/net/usb/huawei_cdc_ncm.c
>=3D=3D> @@ -84,12 +84,13 @@ static int huawei_cdc_ncm_bind(struct usbn=
et
>*usbnet_dev,
>=3D=3D>  	ctx =3D drvstate->ctx;
>=3D=3D> =20
>=3D=3D>  	if (usbnet_dev->status)
>=3D=3D> -		/* CDC-WMC r1.1 requires wMaxCommand to be "at least 256
>=3D=3D> -		 * decimal (0x100)"
>=3D=3D> +		/* The wMaxCommand buffer must be big enough to hold
>=3D=3D> +		 * any message from the modem. Experience has shown
>=3D=3D> +		 * that some replies are more than 256 bytes long
>=3D=3D>  		 */
>=3D=3D>  		subdriver =3D usb_cdc_wdm_register(ctx->control,
>=3D=3D>  						 &usbnet_dev->status->desc,
>=3D=3D> -						 256, /* wMaxCommand */
>=3D=3D> +						 1024, /* wMaxCommand */
>=3D=3D>  						 huawei_cdc_ncm_wdm_manage_power);
>=3D=3D>  	if (IS_ERR(subdriver)) {
>=3D=3D>  		ret =3D PTR_ERR(subdriver);
>=3D=3D
>=3D=3D
>=3D=3D
