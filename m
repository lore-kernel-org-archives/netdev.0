From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Wed, 18 May 2011 13:38:19 +0300
Message-ID: <20110518103819.GL7589@redhat.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop>
 <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop>
 <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain>
 <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305671318.10756.49.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2011 at 03:28:38PM -0700, Shirley Ma wrote:
> On Tue, 2011-05-17 at 23:48 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
> > > Hello Michael,
> > >
> > > Looks like to use a new flag requires more time/work. I am thinki=
ng
> > > whether we can just use HIGHDMA flag to enable zero-copy in macvt=
ap
> > to
> > > avoid the new flag for now since mavctap uses real NICs as lower
> > device?
> >=20
> > Is there any other restriction besides requiring driver to not recy=
cle
> > the skb? Are there any drivers that recycle TX skbs?=20

Not just recycling skbs, keeping reference to any of the pages in the
skb. Another requirement is to invoke the callback
in a timely fashion.  For example virtio-net doesn't limit the time unt=
il
that happens (skbs are only freed when some other packet is
transmitted), so we need to avoid zcopy for such (nested-virt)
scenarious, right?
>=20
> Not more other restrictions, skb clone is OK. pskb_expand_head() look=
s
> OK to me from code review.

Hmm. pskb_expand_head calls skb_release_data while keeping
references to pages. How is that ok? What do I miss?

> Currently there is no drivers recycle TX skbs.
>=20
> Thanks
> Shirley

Well, with e.g. bridge or veth the skb might enter
the host networking stack. Once that happens, we lose
track of the pages. Or is there anything that
prevents such setups?

--=20
MST
