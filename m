From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tg3: fix VLAN tagging regression
Date: Wed, 21 Sep 2011 00:08:53 +0200
Message-ID: <1316556533.5832.1.camel@edumazet-laptop>
References: <4E78FC38.7040903@kasperkp.dk>
	 <20110920210929.GA9652@mcarlson.broadcom.com>
	 <CAEP_g=9V=5zHqwz710TSuRSqTdo1kqkKF2VEEV6K3Tv1zupegg@mail.gmail.com>
	 <4E790C5E.5000000@kasperkp.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kasper Pedersen <kernel@kasperkp.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E790C5E.5000000@kasperkp.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 20 septembre 2011 =C3=A0 23:57 +0200, Kasper Pedersen a =C3=A9=
crit :
> On 09/20/2011 11:27 PM, Jesse Gross wrote:
>=20
> > On Tue, Sep 20, 2011 at 2:09 PM, Matt Carlson <mcarlson@broadcom.co=
m> wrote:
> >> On Tue, Sep 20, 2011 at 01:48:56PM -0700, Kasper Pedersen wrote:
> >>> commit 92cd3a17ce9c719abb4c28dee3438e0c641f8de4
> >>>     tg3: Simplify tx bd assignments
> >>>
> >>> broke VLAN tagging on outbound packets.
> >>> It ifdef'ed BCM_KERNEL_SUPPORTS_8021Q, but this
> >>> is not set anywhere. So vlan never gets set, and
> >>> all packets are sent with vlan=3D0.
> >>>
> >>> Change to use the CONFIG_VLAN_xxx defines instead.
> >>> Tested on BCM5721 rev 11.
> >>>
> >>> Signed-off-by: Kasper Pedersen <kernel@kasperkp.dk>
> >>
> >> Yes.  This is correct.
> >>
> >> Acked-by: Matt Carlson <mcarlson@broadcom.com>
> >=20
> > Actually, please don't do this.  Those config #define's refer to th=
e
> > 802.1q module that creates vlan devices only.  The rest of the netw=
ork
> > stack has code for dealing with vlan packets that is not protected =
by
> > config guards, so there's no reason that drivers should be.  The
> > correct thing to do here is just drop the test altogether and
> > unconditionally include the code.
> >=20
>=20
>=20
> currently testing, and will post a just-remove-ifdef in a few hours,
> assuming it behaves as expected on a no-802.1q-module config.
>=20
>=20
> tg3 has one more place where this is done, and it looks as if the cod=
e
> in that location doesn't quite mesh with the comment.

Thanks for finding this bug, this hit me last day on a BCM5755M but I
had no time to investigate.
