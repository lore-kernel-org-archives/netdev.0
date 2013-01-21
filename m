From: Yauheni Kaliuta <y.kaliuta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 2/3] net: cdc_mbim: send ZLP after max sized NTBs
Date: Mon, 21 Jan 2013 18:56:10 +0200
Message-ID: <87wqv64gr9.fsf@home.kaliuta.org>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<1358783440-11459-3-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: =?utf-8?Q?Bj=C3=B8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358783440-11459-3-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
 =?utf-8?Q?=28=22Bj=C3=B8rn?= Mork"'s
	message of "Mon, 21 Jan 2013 16:50:39 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi, Bj=C3=B8rn!

>>>>> "BM" =3D=3D Bj=C3=B8rn Mork writes:

 > We normally avoid sending ZLPs by padding NTBs with a zero byte
 > if the NTB is shorter than dwNtbOutMaxSize, resulting in a short
 > USB packet instead of a ZLP.  But in the case where the NTB length
 > is exactly dwNtbOutMaxSize and this is an exact multiplum of
 > wMaxPacketSize, then we must send a ZLP.

The idea of NCM was to avoid extra ZLPs. If your transfer is exactly
dwNtbOutMaxSize, it's known, you can submit such request on the receive=
r
side and you do not need any EOT indicatation, so the frametime can be
used for useful data.

I didn't check MBIM specs, but I guess, it wasn't changed. But better g=
et
Alexey's answer for sure.

 > This fixes an issue seen on a Sierra Wireless MC7710 device
 > where the transmission would fail whenever we ended up padding
 > the NTBs to max size.

Is it buggy?

 > Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
 > ---
 >  drivers/net/usb/cdc_mbim.c |    2 +-
 >  1 file changed, 1 insertion(+), 1 deletion(-)

 > diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
 > index 42f51c7..3a5673a 100644
 > --- a/drivers/net/usb/cdc_mbim.c
 > +++ b/drivers/net/usb/cdc_mbim.c
 > @@ -366,7 +366,7 @@ err:
 > =20
 >  static const struct driver_info cdc_mbim_info =3D {
 >          .description =3D "CDC MBIM",
 > -        .flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
 > +        .flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN |=
 FLAG_SEND_ZLP,
 >          .bind =3D cdc_mbim_bind,
 >          .unbind =3D cdc_mbim_unbind,
 >          .manage_power =3D cdc_mbim_manage_power,
 > --=20
 > 1.7.10.4



--=20
WBR, Yauheni Kaliuta
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
