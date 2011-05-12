From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Thu, 12 May 2011 09:21:32 +0200
Message-ID: <20110512072132.GA31817@tuxmaker.boeblingen.de.ibm.com>
References: <20110512054318.241733700@de.ibm.com> <20110512054415.435611676@de.ibm.com> <BANLkTinO4Hity5++152Ff-RuACFDtoAV2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:45074 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab1ELHVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 03:21:35 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTinO4Hity5++152Ff-RuACFDtoAV2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2011 at 07:59:45AM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> 2011/5/12  <frank.blaschka@de.ibm.com>:
> > From: Frank Blaschka <frank.blaschka@de.ibm.com>
> >
> > Set rx csum default to hw checksumming again.
> > Remove sysfs interface for rx csum (checksumming) and TSO (large_se=
nd).
> > With the new hw_features it does not work to keep the old sysfs
> > interface in parallel. Convert options.checksum_type to new hw_feat=
ures.
> [...]
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* hw may have c=
hanged during offline or recovery */
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!qeth_is_sup=
ported(card, IPA_INBOUND_CHECKSUM)) {
> [...]
>=20
> This check should go to ndo_fix_features callback. If it fails then
> just return features &~NETIF_F_RXCSUM from there ...
>=20
> > +update_feature:
> > + =C2=A0 =C2=A0 =C2=A0 rtnl_lock();
> > + =C2=A0 =C2=A0 =C2=A0 card->dev->hw_features &=3D ~NETIF_F_RXCSUM;
> > + =C2=A0 =C2=A0 =C2=A0 card->dev->features &=3D ~NETIF_F_RXCSUM;
> > + =C2=A0 =C2=A0 =C2=A0 netdev_update_features(card->dev);
> > + =C2=A0 =C2=A0 =C2=A0 rtnl_unlock();
>=20
> ... and then this should be just:
> rtnl_lock();
> netdev_update_features(card->dev);
> rtnl_unlock();
>
This code is part of the recovery, assuming the recovery detects the hw
has lost it's rx csum capability I still don't understand how ndo_fix_f=
eatures
come into play?
=20
> BTW, How is the recovery process protected from interface removal if
> it's not run under rtnl_lock?
>
The s/390 devices have a two stage device concept. For each netdevice t=
here is
a corresponding ccw_group device. Removing the netdevice is controlled =
by the
ccw_group device. The recovery process is synchronized with the ccw_gro=
up
device.

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
