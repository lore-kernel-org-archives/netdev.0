From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: axnet_cs / pcnet_cs: moving PCMCIA_DEVICE_PROD_ID for Netgear
 FA411
Date: Fri, 21 Nov 2008 21:48:12 +0900
Message-ID: <20081121214812.b03d7166.komurojun-mbn@nifty.com>
References: <4925F6F1.9010305@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Cord Walter <cord.walter@gmx.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756074AbYKUMxf@vger.kernel.org>
In-Reply-To: <4925F6F1.9010305@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Nov 2008 00:46:57 +0100
Cord Walter <cord.walter@gmx.de> wrote:

> after noticing that my Netgear FA411 (PCMCIA-NIC) [1] stopped working=
 with
> the release of the 2.6.25 kernel (sidux-version),

You are right. My patch has a bug.
The patch below fixes this problem.

By the way,
(1) Does your FA411 work properly with the pcnet_cs driver before?
(2) Please post the full-dmesg (axnet_cs).


--- linux-2.6.28-rc6/drivers/net/pcmcia/pcnet_cs.c.orig	2008-11-21 21:3=
9:08.000000000 +0900
+++ linux-2.6.28-rc6/drivers/net/pcmcia/pcnet_cs.c	2008-11-21 21:39:24.=
000000000 +0900
@@ -587,7 +587,7 @@ static int pcnet_config(struct pcmcia_de
     }
=20
     if ((link->conf.ConfigBase =3D=3D 0x03c0)
-	&& (link->manf_id =3D=3D 0x149) && (link->card_id =3D 0xc1ab)) {
+	&& (link->manf_id =3D=3D 0x149) && (link->card_id =3D=3D 0xc1ab)) {
 	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
 	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
 	goto failed;


Best Regards
Komuro


> Hi,
>=20
> after noticing that my Netgear FA411 (PCMCIA-NIC) [1] stopped working=
 with
> the release of the 2.6.25 kernel (sidux-version), I checked the
> respective driver sources and noticed that the pcnet_cs driver bailed
> out with "use axnet_cs instead" for the Netgear FA411, but axnet_cs
> doesn't claim this ID.
>=20
> I compiled a kernel with the PCMCIA-ID for the netgear card moved to
> axnet_cs from pcnet_cs which worked. I then contacted sidux-kernel
> maintainer Stefan Lippers-Hollmann who turned the info into this patc=
h
> and integrated it into the kernel:
>=20
> <http://svn.berlios.de/svnroot/repos/fullstory/linux-sidux-2.6/trunk/=
debian/patches/features/2.6.27.4_PCMCIA_move-PCMCIA-ID-for-Netgear-FA41=
1-from-pcnet_cs-to-axnet_cs.patch>
>=20
> This works for me and AFAIK there were no reports of any breakage for
> other devices on sidux-support.
>=20
> This looks like a trivial patch, but since I have very limited
> experience with kernel modifications  I might be woefully wrong there=
=2E
> But if there are no side effects of this patch, is it possible to get=
 it
> into the official kernel?
>=20
> I can provide more detailed information on the affected hardware if
> necessary.
>=20
> -cord
>=20
>=20
> [1]
> Socket 1 Device 0:      [axnet_cs]              (bus ID: 1.0)
>         Configuration:  state: on
>         Product Name:   NETGEAR FA411 Fast Ethernet
>         Identification: manf_id: 0x0149 card_id: 0x0411
>                         function: 6 (network)
>                         prod_id(1): "NETGEAR" (0x9aa79dc3)
>                         prod_id(2): "FA411" (0x40fad875)
>                         prod_id(3): "Fast Ethernet" (0xb4be14e3)
>                         prod_id(4): --- (---)
> --=20
> Cord Walter
> email: cord.walter@gmx.de
>=20
> Weil es niemanden etwas angeht, dass ich nichts zu verbergen habe:
> http://www.gnupg.org/
> http://www.truecrypt.org/
> ...und =C3=BCberhaupt: http://www.FreiheitstattAngst.de
>=20
>=20
>=20


--=20
Komuro <komurojun-mbn@nifty.com>
