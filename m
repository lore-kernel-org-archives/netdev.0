From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/2] Using LP firmware for taking advantage of the low-power
 capabilities.
Date: Wed, 19 Sep 2012 10:08:33 -0500
Message-ID: <5059DFF1.4060405@lwfinger.net>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk> <1348053493-22955-2-git-send-email-jarl@softace.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	=?UTF-8?B?R8OhYm9yIFN0ZWZh?= =?UTF-8?B?bmlr?=
	<netrolller.3d@gmail.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org
To: Jarl Friis <jarl@softace.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:46745 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209Ab2ISPIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 11:08:37 -0400
In-Reply-To: <1348053493-22955-2-git-send-email-jarl@softace.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2012 06:18 AM, Jarl Friis wrote:
> This is using the LP specific firmware to better take advantage of th=
e
> Low-Power capabilities.
>
> Signed-off-by: Jarl Friis <jarl@softace.dk>
> ---
>   drivers/net/wireless/b43/main.c |   16 ++++++++++++++--
>   1 file changed, 14 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b=
43/main.c
> index 202a0eb..9ee6030 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -8,6 +8,7 @@
>     Copyright (c) 2005 Danny van Dyk <kugelfang@gentoo.org>
>     Copyright (c) 2005 Andreas Jaggi <andreas.jaggi@waterwave.ch>
>     Copyright (c) 2010-2011 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com=
>
> +  Copyright (c) 2012 Jarl Friis <jarl@softace.dk>
>
>     SDIO support
>     Copyright (c) 2009 Albert Herranz <albert_herranz@yahoo.es>
> @@ -72,6 +73,7 @@ MODULE_FIRMWARE("b43/ucode11.fw");
>   MODULE_FIRMWARE("b43/ucode13.fw");
>   MODULE_FIRMWARE("b43/ucode14.fw");
>   MODULE_FIRMWARE("b43/ucode15.fw");
> +MODULE_FIRMWARE("b43/ucode16_lp.fw");
>   MODULE_FIRMWARE("b43/ucode16_mimo.fw");
>   MODULE_FIRMWARE("b43/ucode5.fw");
>   MODULE_FIRMWARE("b43/ucode9.fw");
> @@ -2208,6 +2210,12 @@ static int b43_try_request_fw(struct b43_reque=
st_fw_context *ctx)
>   			else
>   				goto err_no_ucode;
>   			break;
> +		case B43_PHYTYPE_LP:
> +			if (rev >=3D 16)
> +				filename =3D "ucode16_lp";
> +			else
> +				goto err_no_ucode;
> +			break;
>   		case B43_PHYTYPE_HT:
>   			if (rev =3D=3D 29)
>   				filename =3D "ucode29_mimo";
> @@ -2277,8 +2285,10 @@ static int b43_try_request_fw(struct b43_reque=
st_fw_context *ctx)
>   			filename =3D "lp0initvals13";
>   		else if (rev =3D=3D 14)
>   			filename =3D "lp0initvals14";
> -		else if (rev >=3D 15)
> +		else if (rev =3D=3D 15)
>   			filename =3D "lp0initvals15";
> +		else if (rev >=3D 16)
> +			filename =3D "lp0initvals16";
>   		else
>   			goto err_no_initvals;
>   		break;
> @@ -2336,8 +2346,10 @@ static int b43_try_request_fw(struct b43_reque=
st_fw_context *ctx)
>   			filename =3D "lp0bsinitvals13";
>   		else if (rev =3D=3D 14)
>   			filename =3D "lp0bsinitvals14";
> -		else if (rev >=3D 15)
> +		else if (rev =3D=3D 15)
>   			filename =3D "lp0bsinitvals15";
> +		else if (rev >=3D 16)
> +			filename =3D "lp0bsinitvals16";
>   		else
>   			goto err_no_initvals;
>   		break;

I have some questions about this patch. Where did you get the informati=
on needed=20
to make these changes? Did it come from reverse engineering some Broadc=
om code,=20
or did you look at their actual code? There is a great deal of differen=
ce=20
relative to our "clean-room" status. Anyone that has seen non-GPL Broad=
com=20
material cannot contribute code to b43.

Have you tested this code on devices with rev>=3D16?

Now for some comments: This patch also needs the "b43:" added to the su=
bject. In=20
addition, you appear to have at least one white-space error in the=20
MODULE_FIRMWARE line. Is the addition of your copyright to the driver w=
arranted=20
by this change? For example, I have made much larger contributions to b=
43 over=20
the years before I started doing reverse-engineering on this driver, bu=
t I never=20
added my copyright. Your "Signed-off-by" implies copyright for the patc=
h.

Larry
