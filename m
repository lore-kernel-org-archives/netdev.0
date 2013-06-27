From: =?iso-8859-1?Q?Christoph_M=FCllner?=
	<christoph.muellner@theobroma-systems.com>
Subject: Re: [PATCH] net: fec: Fix multicast list setup in fec_restart().
Date: Thu, 27 Jun 2013 19:14:37 +0200
Message-ID: <C2B6127F-2C6D-49ED-9E45-5FEE9CC1BCE4@theobroma-systems.com>
References: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com> <CAOMZO5CyK9S-Wmm+ihBeMCaDBJyxBb-vSQjzZiKrmz74mb=vDw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: multipart/mixed; boundary="Apple-Mail=_1F50839C-3ED3-4E5B-A49C-50187A01BA7D"
Cc: linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5CyK9S-Wmm+ihBeMCaDBJyxBb-vSQjzZiKrmz74mb=vDw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Apple-Mail=_1F50839C-3ED3-4E5B-A49C-50187A01BA7D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

On Jun 21, 2013, at 7:15 PM, Fabio Estevam <festevam@gmail.com> wrote:

> On Fri, Jun 21, 2013 at 1:40 PM, Christoph M=FCllner
> <christoph.muellner@theobroma-systems.com> wrote:
>=20
>> @@ -472,8 +474,7 @@ fec_restart(struct net_device *ndev, int duplex)
>>        writel(0xffc00000, fep->hwp + FEC_IEVENT);
>>=20
>>        /* Reset all multicast. */
>=20
> Should this comment be removed/updated now?

Is updated in the attached patch.
Thank you for the feedback!

>=20
>> -       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
>> -       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
>> +       set_multicast_list(ndev);


--Apple-Mail=_1F50839C-3ED3-4E5B-A49C-50187A01BA7D
Content-Disposition: attachment;
	filename=0001-net-fec-Fix-multicast-list-setup-in-fec_restart.patch
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="0001-net-fec-Fix-multicast-list-setup-in-fec_restart.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=20efc0a82aa810cf3c37505cf3c753ad6f1cf33572=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Christoph=20Muellner=20=
<christoph.muellner@theobroma-systems.com>=0ADate:=20Fri,=2021=20Jun=20=
2013=2017:59:52=20+0200=0ASubject:=20[PATCH]=20net:=20fec:=20Fix=20=
multicast=20list=20setup=20in=20fec_restart().=0A=0ASetup=20the=20=
multicast=20list=20of=20the=20net_device=20instead=20of=0Aclearing=20it=20=
blindly.=20This=20restores=20the=20multicast=20groups=0Ain=20case=20of=20=
a=20link=20down/up=20event=20or=20when=20resuming=20from=0Asuspend.=0A=0A=
Signed-off-by:=20Christoph=20Muellner=20=
<christoph.muellner@theobroma-systems.com>=0A---=0A=20=
drivers/net/ethernet/freescale/fec_main.c=20|=20=20=20=207=20++++---=0A=20=
1=20files=20changed,=204=20insertions(+),=203=20deletions(-)=0A=0Adiff=20=
--git=20a/drivers/net/ethernet/freescale/fec_main.c=20=
b/drivers/net/ethernet/freescale/fec_main.c=0Aindex=20d48099f..4c32709=20=
100644=0A---=20a/drivers/net/ethernet/freescale/fec_main.c=0A+++=20=
b/drivers/net/ethernet/freescale/fec_main.c=0A@@=20-60,6=20+60,8=20@@=0A=20=
=0A=20#include=20"fec.h"=0A=20=0A+static=20void=20=
set_multicast_list(struct=20net_device=20*ndev);=0A+=0A=20#if=20=
defined(CONFIG_ARM)=0A=20#define=20FEC_ALIGNMENT=090xf=0A=20#else=0A@@=20=
-471,9=20+473,8=20@@=20fec_restart(struct=20net_device=20*ndev,=20int=20=
duplex)=0A=20=09/*=20Clear=20any=20outstanding=20interrupt.=20*/=0A=20=09=
writel(0xffc00000,=20fep->hwp=20+=20FEC_IEVENT);=0A=20=0A-=09/*=20Reset=20=
all=20multicast.=09*/=0A-=09writel(0,=20fep->hwp=20+=20=
FEC_GRP_HASH_TABLE_HIGH);=0A-=09writel(0,=20fep->hwp=20+=20=
FEC_GRP_HASH_TABLE_LOW);=0A+=09/*=20Setup=20multicast=20filter.=20*/=0A+=09=
set_multicast_list(ndev);=0A=20#ifndef=20CONFIG_M5272=0A=20=09writel(0,=20=
fep->hwp=20+=20FEC_HASH_TABLE_HIGH);=0A=20=09writel(0,=20fep->hwp=20+=20=
FEC_HASH_TABLE_LOW);=0A--=20=0A1.7.4.1=0A=0A=

--Apple-Mail=_1F50839C-3ED3-4E5B-A49C-50187A01BA7D--
