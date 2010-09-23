From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] de2104x: disable autonegotiation on broken hardware
Date: Thu, 23 Sep 2010 17:03:13 -0400
Message-ID: <AANLkTikwXyr4pH5rqkoXpiYvkvpLc7s8tq-EwmM1+r7m@mail.gmail.com>
References: <201009232259.20261.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009232259.20261.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2010 at 4:59 PM, Ondrej Zary <linux@rainbow-software.or=
g> wrote:
> At least on older 21041-AA chips (mine is rev. 11), TP duplex autoneg=
otiation
> causes the card not to work at all (link is up but no packets are tra=
nsmitted).
>
> de4x5 disables autonegotiation completely. But it seems to work on ne=
wer
> (21041-PA rev. 21) so disable it only on rev<20 chips.
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
>
> --- linux-2.6.36-rc3-orig/drivers/net/tulip/de2104x.c =C2=A0 2010-08-=
29 17:36:04.000000000 +0200
> +++ linux-2.6.36-rc3/drivers/net/tulip/de2104x.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A02010-09-24 00:27:41.000000000 +0200
> @@ -364,6 +364,8 @@ static u16 t21040_csr15[] =3D { 0, 0, 0x00
> =C2=A0/* 21041 transceiver register settings: TP AUTO, BNC, AUI, TP, =
TP FD*/
> =C2=A0static u16 t21041_csr13[] =3D { 0xEF01, 0xEF09, 0xEF09, 0xEF01,=
 0xEF09, };
> =C2=A0static u16 t21041_csr14[] =3D { 0xFFFF, 0xF7FD, 0xF7FD, 0x6F3F,=
 0x6F3D, };
> +/* If on-chip autonegotiation is broken, use half-duplex (FF3F) inst=
ead */
> +static u16 t21041_csr14_brk[] =3D { 0xFF3F, 0xF7FD, 0xF7FD, 0x6F3F, =
0x6F3D, };
> =C2=A0static u16 t21041_csr15[] =3D { 0x0008, 0x0006, 0x000E, 0x0008,=
 0x0008, };
>
>
> @@ -1911,8 +1913,14 @@ fill_defaults:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < DE_MAX_MEDIA; i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (de->media[=
i].csr13 =3D=3D 0xffff)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0de->media[i].csr13 =3D t21041_csr13[i];
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (de->media[i].c=
sr14 =3D=3D 0xffff)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 de->media[i].csr14 =3D t21041_csr14[i];
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (de->media[i].c=
sr14 =3D=3D 0xffff) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /* autonegotiation is broken at least on some chip
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0revisions - rev. 0x21 works, 0x11 does not */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (de->pdev->revision < 0x20)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 de->media[i].csr14 =3D t21041_csr14=
_brk[i];
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 de->media[i].csr14 =3D t21041_csr14=
[i];
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }

Interesting...  I never knew about that quirk.

Acked-by: Jeff Garzik <jgarzik@redhat.com>
