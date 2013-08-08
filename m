From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Wed, 07 Aug 2013 17:12:32 -0700
Message-ID: <1375920752.4004.71.camel@edumazet-glaptop>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Vitaly E. Lavrov" <lve@guap.ru>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:64397 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933010Ab3HHAMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 20:12:34 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so2742263pad.32
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 17:12:34 -0700 (PDT)
In-Reply-To: <5202E153.4060202@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 17:07 -0700, Ben Greear wrote:
> On 07/25/2013 10:20 AM, Vitaly E. Lavrov wrote:
> > The network device VETH can't support the feature NETIF_F_HW_CSUM.
> > All locally generated packets have invalid checksum.
> > Wrong commit http://git.kernel.org/cgit/linux/kernel/git/torvalds/l=
inux.git/commit/?id=3D8093315a91340bca52549044975d8c7f673b28a1 ( kernel=
 3.9.0 )
> >
> > Workaround "ethtool -K vethX tx off"
> >
> > Possible patch:
> >
> > diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> > index 177f911..3db97da 100644
> > --- a/drivers/net/veth.c
> > +++ b/drivers/net/veth.c
> > @@ -254,7 +254,7 @@ static const struct net_device_ops veth_netdev_=
ops =3D {
> >   };
> >
> >   #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_AL=
L_TSO |    \
> > -                      NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_H=
IGHDMA | \
> > +                      NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
> >                         NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_C=
TAG_RX | \
> >                         NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_S=
TAG_RX )
>=20
> I see the same problem.
>=20
> My test case is a bit complicated, but the gist is that I have a VETH
> pair, one with IP (veth1), one connected to a bridge-like-thing (veth=
2).
>=20
> The UDP frames sent on veth1 appear on veth2, and when I sniff veth2,
> the packets show broken checksum.  The work-around mentioned in Vital=
y's
> email above fixes the problem for me (I did not try the patch yet).
>=20
> Eric:  You responded originally that you needed more info.  If
> my explanation above is not sufficient, please let me know what
> you need...
>=20

tcpdump is known to display wrong checksums, its not a reason to disabl=
e
tx checksums on our interfaces and kill performance.

       -K     Don't  attempt to verify IP, TCP, or UDP checksums.  This
is useful for interfaces that perform some or all of those checksum
calculation in hardware; other=E2=80=90
              wise, all outgoing TCP checksums will be flagged as bad.


So we need more information than 'my trcpdump says checksums are wrong'

We could also disable TSO because : It sends packets bigger than MTU,
this can not be good ;)
