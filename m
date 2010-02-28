From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbe: Do not allocate too many
 netdev txqueues
Date: Sun, 28 Feb 2010 04:57:00 +0100
Message-ID: <1267329420.9082.28.camel@edumazet-laptop>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>
	 <20100226091519.19796.82441.stgit@localhost.localdomain>
	 <1267193054.9082.12.camel@edumazet-laptop>
	 <1267318956.2052.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:46732 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030425Ab0B1D5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 22:57:08 -0500
Received: by bwz1 with SMTP id 1so512090bwz.21
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2010 19:57:04 -0800 (PST)
In-Reply-To: <1267318956.2052.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 27 f=C3=A9vrier 2010 =C3=A0 17:02 -0800, Peter P Waskiewicz J=
r a =C3=A9crit :
> On Fri, 2010-02-26 at 06:04 -0800, Eric Dumazet wrote:
> > Le vendredi 26 f=C3=A9vrier 2010 =C3=A0 01:15 -0800, Jeff Kirsher a=
 =C3=A9crit :
> > > +	if (ii->mac =3D=3D ixgbe_mac_82598EB)
> > > +		indices =3D min_t(unsigned int, indices, IXGBE_MAX_RSS_INDICES=
);
> > > +	else
> > > +		indices =3D min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICE=
S);
> > > +
> > > +	indices =3D max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES)=
;
> > > +#ifdef IXGBE_FCOE
> > > +	indices +=3D min_t(unsigned int, num_possible_cpus(),
> > > +			 IXGBE_MAX_FCOE_INDICES);
> > > +#endif
> > > +	indices =3D min_t(unsigned int, indices, MAX_TX_QUEUES);
> > > +	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indi=
ces);
> > >  	if (!netdev) {
> > >  		err =3D -ENOMEM;
> > >  		goto err_alloc_etherdev;
> > >=20
> >=20
> > Thanks Jeff, but what is the reason for limiting to MAX_TX_QUEUES ?
> > Is it a hardware issue ?
> >=20
>=20
> MAX_TX_QUEUES is 128, which is the maximum the 82599 device supports =
in
> hardware (82598 supports 32 Tx queues).  I'm not sure why you'd ever
> want to have more Tx queues than what you have in the network device.

I was not sure MAX_TX_QUEUES capping was still necessary after the
block :

if (ii->mac =3D=3D ixgbe_mac_82598EB)
          indices =3D min_t(unsigned int, indices, IXGBE_MAX_RSS_INDICE=
S);
else
          indices =3D min_t(unsigned int, indices,
IXGBE_MAX_FDIR_INDICES);

indices =3D max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES);
#ifdef IXGBE_FCOE
	indices +=3D min_t(unsigned int, num_possible_cpus(),
                    IXGBE_MAX_FCOE_INDICES);
#endif

So I asked to be sure that MAX_TX_QUEUES was not a leftover from the
previous default allocation.

Thanks


