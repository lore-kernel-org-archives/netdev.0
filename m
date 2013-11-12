From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCHv2 3/4] of: provide a binding for fixed link PHYs
Date: Tue, 12 Nov 2013 16:29:14 +0000
Message-ID: <20131112162914.GE4237@e106331-lin.cambridge.arm.com>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130918042923.5D845C42CF7@trevor.secretlab.ca>
 <20130918181112.56c10dde@skate>
 <1811694.J4B6oUpKxP@lenovo>
 <20131112123746.EAEF0C42283@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Lior Amsalem <alior@marvell.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Grant Likely <grant.likely@secretlab.ca>,
	Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:39730 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756109Ab3KLQ3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 11:29:54 -0500
Content-Disposition: inline
In-Reply-To: <20131112123746.EAEF0C42283@trevor.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, Grant,

On Tue, Nov 12, 2013 at 12:37:46PM +0000, Grant Likely wrote:
> On Fri, 25 Oct 2013 05:40:57 +0100, Florian Fainelli <florian@openwrt=
=2Eorg> wrote:
> > Le mercredi 18 septembre 2013, 18:11:12 Thomas Petazzoni a =C3=83=C2=
=A9crit :
> > > Dear Grant Likely,
> > >=20
> > > On Tue, 17 Sep 2013 23:29:23 -0500, Grant Likely wrote:
> > > > I understand what you're trying to do here, but it causes a tro=
ublesome
> > > > leakage of implementation detail into the binding, making the w=
hole
> > > > thing look very odd. This binding tries to make a fixed link lo=
ok
> > > > exactly like a real PHY even to the point of including a phandl=
e to the
> > > > phy. But having a phandle to a node which is *always* a direct =
child of
> > > > the MAC node is redundant and a rather looney. Yes, doing it th=
at way
> > > > makes it easy for of_phy_find_device() to be transparent for fi=
xed link,
> > > > but that should *not* drive bindings, especially when that make=
s the
> > > > binding really rather weird.
> > > >=20
> > > > Second, this new binding doesn't provide anything over and abov=
e the
> > > > existing fixed-link binding. It may not be pretty, but it is
> > > > estabilshed.
> > >=20
> > > Have you followed the past discussions about this patch set? Basi=
cally
> > > the *only* feedback I received on RFCv1 is that the fixed-link pr=
operty
> > > sucks, and everybody (including the known Device Tree binding
> > > maintainer Mark Rutland) suggested to not use the fixed-link mech=
anism.
> > > See http://article.gmane.org/gmane.linux.network/276932, where Ma=
rk
> > > said:
> > >=20
> > > ""
> > > I'm not sure grouping these values together is the best way of ha=
ndling
> > > this. It's rather opaque, and inflexible for future extension.
> > > ""
> > >=20
> > > So, please DT maintainers, tell me what you want. I honestly don'=
t care
> > > whether fixed-link or a separate node is chosen. However, I do ca=
re
> > > about being dragged around between two solutions just because the
> > > former DT maintainer and the new DT maintainers do not agree.
>=20
> I've been sleepy on this issue, which limits how much I can push. I'l=
l
> say one more thing on the issue (below) and then leave the decision u=
p
> to Mark. I trust him and he knows what he is doing.
>=20
> > Since I would like to move forward so I can one day use that bindin=
g in a=20
> > real-life product, I am going to go for Mark's side which happens t=
o be how I=20
> > want the binding to look like.
> >=20
> > Do we all agree that the new binding is just way better than the ol=
d one? In=20
> > light of the recent unstable DT ABI discussion, we can still contin=
ue parsing=20
> > the old one for the sake of compatibility.
>=20
> Regardless of what you want it to look like, does the old binding wor=
k
> for your purposes? If yes then use it. The only valid reason for
> creating a new binding is if the old one doesn't work for a specific
> (not theoretical) use case.

I think the issue here was that I am not versed in the history of all o=
f
the existing bindings. While I'm not keen on the existing fixed-link
property and I think it should be done differently were it being create=
d
from scratch today, as Grant has pointed out we're already supporting i=
t
today, and adding a new binding is going to make the code handling it
more complex.

If fixed-link works for your use case today, then use fixed-link.

If we have a valid reason to create a new binding, we should. At the
moment I think the only egregious portion of the binding is the globall=
y
unique fake PHY id, and if that causes issues we should be able to
assign IDs within Linux ignoring the values in the DT, or reorganise
things such that the arbitrary ID doesn't matter.

If there are configurations we need to support that the fixed-link
property cannot encode, then I think we should go ahead with the bindin=
g
style that you are proposing today. However, we don't need to go with i=
t
right away, and we can continue to support fixed-link regardless.

I apologise for the lack of consistency here, and I'm sorry that I've
delayed this series for so long.

Thanks,
Mark.
