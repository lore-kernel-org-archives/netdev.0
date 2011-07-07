From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 1/5] sky2: force receive checksum when using
 RSS on some hardware
Date: Thu, 7 Jul 2011 10:13:22 -0700
Message-ID: <20110707101322.784409eb@nehalam.ftrdhcpuser.net>
References: <20110707155056.939223264@vyatta.com>
	<20110707155212.000920741@vyatta.com>
	<CAHXqBF+Ha9XaMDB0x1XBD633mj2b6Jxmg9U_JSokrov90gPA-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49265 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab1GGRNX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 13:13:23 -0400
In-Reply-To: <CAHXqBF+Ha9XaMDB0x1XBD633mj2b6Jxmg9U_JSokrov90gPA-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Jul 2011 19:04:46 +0200
Micha=B3 Miros=B3aw <mirqus@gmail.com> wrote:

> 2011/7/7 Stephen Hemminger <shemminger@vyatta.com>:
> > Found when reviewing the vendor driver. Apparently some chip versio=
ns
> > require receive checksumming to be enabled in order for RSS to work=
=2E
> > Rather than silently enabling checksumming which is what the vendor
> > driver does, return an error to the user instead.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> >
> > --- a/drivers/net/sky2.c =A0 =A0 =A0 =A02011-07-07 08:36:10.7480033=
69 -0700
> > +++ b/drivers/net/sky2.c =A0 =A0 =A0 =A02011-07-07 08:36:37.3720045=
95 -0700
> > @@ -2996,7 +2996,8 @@ static int __devinit sky2_init(struct sk
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hw->flags =3D SKY2_HW_GIGABIT
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| SKY2_HW_NEWER_PHY
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| SKY2_HW_NEW_LE
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | SKY2_HW_ADV_POWER_C=
TL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | SKY2_HW_ADV_POWER_C=
TL
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | SKY2_HW_RSS_CHKSUM;
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* New transmit checksum */
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hw->chip_rev !=3D CHIP_REV_YU_EX=
_B0)
> > @@ -3024,7 +3025,7 @@ static int __devinit sky2_init(struct sk
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* The workaround for status conflic=
ts VLAN tag detection. */
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hw->chip_rev =3D=3D CHIP_REV_YU_=
=46E2_A0)
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw->flags |=3D SKY2_H=
W_VLAN_BROKEN;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw->flags |=3D SKY2_H=
W_VLAN_BROKEN | SKY2_HW_RSS_CHKSUM;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> >
> > =A0 =A0 =A0 =A0case CHIP_ID_YUKON_SUPR:
> > @@ -3033,6 +3034,9 @@ static int __devinit sky2_init(struct sk
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| SKY2_HW_NEW_LE
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| SKY2_HW_AUTO_TX_SU=
M
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| SKY2_HW_ADV_POWER_=
CTL;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (hw->chip_rev =3D=3D CHIP_REV_YU_S=
U_A0)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw->flags |=3D SKY2_H=
W_RSS_CHKSUM;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> >
> > =A0 =A0 =A0 =A0case CHIP_ID_YUKON_UL_2:
> > @@ -4187,6 +4191,11 @@ static int sky2_set_features(struct net_
> > =A0 =A0 =A0 =A0struct sky2_port *sky2 =3D netdev_priv(dev);
> > =A0 =A0 =A0 =A0u32 changed =3D dev->features ^ features;
> >
> > + =A0 =A0 =A0 /* Some hardware requires receive checksum for RSS to=
 work. */
> > + =A0 =A0 =A0 if ( (features & (NETIF_F_RXHASH|NETIF_F_RXCSUM)) =3D=
=3D NETIF_F_RXHASH &&
> > + =A0 =A0 =A0 =A0 =A0 =A0(sky2->hw->flags & SKY2_HW_RSS_CHKSUM))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > +
> > =A0 =A0 =A0 =A0if (changed & NETIF_F_RXCSUM) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 on =3D features & NETIF_F_RXCSUM=
;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(sky2->hw, Q_ADDR(rxqadd=
r[sky2->port], Q_CSR),
>=20
> Nah. This won't work as the error is not passed to user (except via
> dmesg) as there is no way to do it. Failing ndo_set_features() withou=
t
> updating dev->features will also prevent other unrelated changes to
> features set.

I think this needs to be fixed in the netdev core then.
There are bound to be hardware types that can support only some combina=
tions
of features. It should be passed back like all other errors.
