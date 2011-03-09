From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Wed, 9 Mar 2011 08:33:39 -0500
Message-ID: <20110309133338.GA18232@hmsreliant.think-freely.org>
References: <4D7249BA.8030401@gmail.com>
 <20110305144314.GC8573@psychotron.redhat.com>
 <4D724DB4.9020207@gmail.com>
 <4D737D00.20406@gmail.com>
 <20110306133413.GB2795@psychotron.redhat.com>
 <20110307125059.GA6053@psychotron.brq.redhat.com>
 <20110307224338.GU11864@gospo.rdu.redhat.com>
 <20110308071350.GA2826@psychotron.redhat.com>
 <20110308134247.GW11864@gospo.rdu.redhat.com>
 <4D76A345.9040200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53118 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213Ab1CINdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 08:33:54 -0500
Content-Disposition: inline
In-Reply-To: <4D76A345.9040200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2011 at 10:44:37PM +0100, Nicolas de Peslo=FCan wrote:
> Le 08/03/2011 14:42, Andy Gospodarek a =E9crit :
> >I'm pretty sure this patch will have the same catastrophic problem y=
our
> >last one did.  By cloning and setting skb2->dev =3D orig_dev you jus=
t
> >inserted a frame identical to the one we received right back into th=
e
> >stack.  It only took a few minutes for my box to melt as one frame o=
n
> >the wire will cause an infinite number of frames to be received by t=
he
> >stack.
>=20
> I agree with Andy. We still keep one reinject (netif_rx), which is
> probably better that two (__netif_receive_skb), but not enough.
>=20
> I really think we need a general framework for late delivery of
> final packets to packet handler registered somewhere in the
> rx_handler path.
>=20
> Jiri, is this patch the one you announced as "I have some kind nice
> solution in mind and I'm going to submit that as a patch later (too
> many patches are in the wind atm)" ?


I've not had time to flesh any of this out, but have you considered the=
 use of
privately allocated net namespaces to define the receive order of frame=
s when
doing multiple re-injections through netif_rx/netif_receive_skb.  If yo=
u
modified the ptype list traversals so validate that dev_net(ptype->dev)=
 =3D=3D
dev_net(skb->dev) before delivery, you could allocate private net names=
paces in
your virutal master drivers (bridges/bonds/vlans) and place the slave d=
evices in
those spaces, so that only the parent device could receive frames on th=
em.

Of course thats going to have its own set of problems to deal with, but=
 it might
be worth considering.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
