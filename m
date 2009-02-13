From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IRDA: mcs7780.c
Date: Fri, 13 Feb 2009 20:05:44 +0100
Message-ID: <4995C488.6090900@gmail.com>
References: <1234514947203.juha_motorsportcom.12982.AOyeEm8k4zVzAxDijub1SA@luukku.com> <49957229.9060401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Juha_Lepp=E4nen?= <juha_motorsportcom@luukku.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:60544 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbZBMTFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 14:05:20 -0500
Received: by fxm13 with SMTP id 13so3859862fxm.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 11:05:17 -0800 (PST)
In-Reply-To: <49957229.9060401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote, On 02/13/2009 02:14 PM:

> Juha Lepp=E4nen wrote:
>> Hi,
>>
>> In recent patch to file
>>
>> drivers/net/irda/mcs7780.c
>=20
> That's this one:
> http://www.spinics.net/lists/netdev/msg88746.html
>=20
> [PATCH] IRDA: cnt is off by 1
>=20
>> I noticed when checking the code around the patch ...
>> In worst case do {...} while loop is executed
>> 101 times --> mcs_get_reg() is executed 101 times...
>> But rval is checked only 100 times.
>=20
> Right, thanks.
>=20
>> If you change the order of the && expressions inside while () to
>>
>> -        } while(cnt++ < 100 && (rval & MCS_IRINTX));
>> +        } while((rval & MCS_IRINTX) && cnt++ < 100);
>=20
>> If you also want exactly 100 maximum mcs_get_reg()
>> tries ( now it is 101 ) ...


Yes, but we don't know what an author of this code exactly
wanted. There is 1 get unused. But 100 can mean here: if
there is more than 100 it's wrong. After this current patch
we check for 100, but 101 positive get is OK, which IMHO
makes it even less readable.

>=20
> I don't think it really matters, does it?


I think it should matter to write logical code, but the
practice is to fix such things in new code or during major
rewriting. Older code is usually changed only when there
is some bug (like triggering an error without counter
overflow). So, unless I miss something, I think there is
no reason here to try David's patience here. ;-)
(But even if I'm wrong - this patch is broken - it doesn't
apply to net-2.6 tree.)

Cheers,
Jarek P.

>=20
>> Happy hacking,
>>
>> Mr. Juha Lepp=E4nen
>> Kuopio, Finland
>=20
> You too.
>=20
> ------------------------------>8----------------8<-------------------=
-----------
> If no prior break occurs, cnt reaches 101 after the loop, so we are s=
till able
> to change speed when cnt has become 100.
>=20
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
> index 7eafdca..8fdfb5a 100644
> --- a/drivers/net/irda/mcs7780.c
> +++ b/drivers/net/irda/mcs7780.c
> @@ -583,9 +583,9 @@ static int mcs_speed_change(struct mcs_cb *mcs)
> =20
>  	do {
>  		mcs_get_reg(mcs, MCS_RESV_REG, &rval);
> -	} while(cnt++ < 100 && (rval & MCS_IRINTX));
> +	} while((rval & MCS_IRINTX) && cnt++ < 100);
> =20
> -	if(cnt >=3D 100) {
> +	if (cnt > 100) {
>  		IRDA_ERROR("unable to change speed\n");
>  		ret =3D -EIO;
>  		goto error;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


