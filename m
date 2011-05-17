From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Tue, 17 May 2011 16:44:25 -0700
Message-ID: <1305675865.10756.63.camel@localhost.localdomain>
References: <1305574128.3456.23.camel@localhost.localdomain>
	 <1305574518.2885.25.camel@bwh-desktop>
	 <1305574680.3456.33.camel@localhost.localdomain>
	 <1305575253.2885.28.camel@bwh-desktop> <20110516211459.GE18148@redhat.com>
	 <1305588738.3456.65.camel@localhost.localdomain>
	 <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
	 <1305671318.10756.49.camel@localhost.localdomain>
	 <BANLkTik6aqP5BVrQNFKrnU3v=KA9ip1RoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <BANLkTik6aqP5BVrQNFKrnU3v=KA9ip1RoA@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-05-18 at 00:58 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> W dniu 18 maja 2011 00:28 u=C5=BCytkownik Shirley Ma <mashirle@us.ibm=
=2Ecom>
> napisa=C5=82:
> > On Tue, 2011-05-17 at 23:48 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> >> 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
> >> > Looks like to use a new flag requires more time/work. I am
> thinking
> >> > whether we can just use HIGHDMA flag to enable zero-copy in
> macvtap
> >> to
> >> > avoid the new flag for now since mavctap uses real NICs as lower
> >> device?
> >>
> >> Is there any other restriction besides requiring driver to not
> recycle
> >> the skb? Are there any drivers that recycle TX skbs?
> > Not more other restrictions, skb clone is OK. pskb_expand_head()
> looks
> > OK to me from code review.
>=20
> > Currently there is no drivers recycle TX skbs.
>=20
> So why do you require the target device to have some flags at all?

We could use macvtap to check lower device HIGHDMA to enable zero-copy,
but I am not sure whether it is sufficient. If it's sufficient then we
don't need to use a new flag here. To be safe, it's better to use a new
flag to enable each device who can pass zero-copy test.

> Do I understand correctly, that this zero-copy feature is about
> packets received from VMs?

Yes, packets sent from VMs, and received in local host for TX zero-copy
here.

Thanks
Shirley



