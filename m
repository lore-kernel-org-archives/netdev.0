From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 08:45:16 -0800
Message-ID: <20091110084516.15659fcc@nehalam>
References: <4AF924A5.1050303@gmail.com>
	<4AF9471C.5080606@gmail.com>
	<412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>
	<4AF95174.3060104@trash.net>
	<412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>
	<4AF95A3D.5060602@trash.net>
	<412e6f7f0911100437g2759eb6dg509af4edb8848291@mail.gmail.com>
	<4AF96055.90509@trash.net>
	<412e6f7f0911100506r6a922b8aoabd359e7e4290ebe@mail.gmail.com>
	<4AF96BF1.5070902@gmail.com>
	<412e6f7f0911100549q68a57ba7s83b11be3a77323a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47745 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757195AbZKJQpm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 11:45:42 -0500
In-Reply-To: <412e6f7f0911100549q68a57ba7s83b11be3a77323a2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 21:49:31 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Tue, Nov 10, 2009 at 9:34 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Changli Gao a =C3=A9crit :
> >
> > I believe Patrick was referring to vlan get_tx_queues() implementat=
ion,
> > but it actually gets values from real device (tb[IFLA_LINK])
> >
> > In your case you'll need to add a new IFLA_NTXQ attribute, and
> > change iproute2 to pass this new attribute at link creation.
> > (check include/linux/if_link.h)
> >
> > ip link add link ..... =C2=A0ntxq 2
> >
> > static int vlan_get_tx_queues(struct net *net,
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nlattr *tb[],
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *num_tx_queues,
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *real_num_tx_queues)
> > {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *real_dev;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!tb[IFLA_LINK])
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINV=
AL;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0real_dev =3D __dev_get_by_index(net, nla=
_get_u32(tb[IFLA_LINK]));
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!real_dev)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOD=
EV;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0*num_tx_queues =C2=A0 =C2=A0 =C2=A0=3D r=
eal_dev->num_tx_queues;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0*real_num_tx_queues =3D real_dev->real_n=
um_tx_queues;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> > }
> >
> >
> >
>=20
> got it. Thanks. BTW: why not merge iproute2 into linux, just like per=
f.
>=20

Distro's would find that hard, also it would cause people to forgot bin=
ary
API compatibility.

--=20
