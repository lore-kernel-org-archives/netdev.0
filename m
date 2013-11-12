From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCHv2 3/4] of: provide a binding for fixed link PHYs
Date: Tue, 12 Nov 2013 21:37:46 +0900
Message-ID: <20131112123746.EAEF0C42283@trevor.secretlab.ca>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com> <20130918042923.5D845C42CF7@trevor.secretlab.ca> <20130918181112.56c10dde@skate> <1811694.J4B6oUpKxP@lenovo>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Lior Amsalem <alior@marvell.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <florian@openwrt.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:39452 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841Ab3KLMhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 07:37:55 -0500
Received: by mail-pb0-f49.google.com with SMTP id um1so4871132pbc.22
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 04:37:55 -0800 (PST)
In-Reply-To: <1811694.J4B6oUpKxP@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Oct 2013 05:40:57 +0100, Florian Fainelli <florian@openwrt.o=
rg> wrote:
> Le mercredi 18 septembre 2013, 18:11:12 Thomas Petazzoni a =C3=A9crit=
 :
> > Dear Grant Likely,
> >=20
> > On Tue, 17 Sep 2013 23:29:23 -0500, Grant Likely wrote:
> > > I understand what you're trying to do here, but it causes a troub=
lesome
> > > leakage of implementation detail into the binding, making the who=
le
> > > thing look very odd. This binding tries to make a fixed link look
> > > exactly like a real PHY even to the point of including a phandle =
to the
> > > phy. But having a phandle to a node which is *always* a direct ch=
ild of
> > > the MAC node is redundant and a rather looney. Yes, doing it that=
 way
> > > makes it easy for of_phy_find_device() to be transparent for fixe=
d link,
> > > but that should *not* drive bindings, especially when that makes =
the
> > > binding really rather weird.
> > >=20
> > > Second, this new binding doesn't provide anything over and above =
the
> > > existing fixed-link binding. It may not be pretty, but it is
> > > estabilshed.
> >=20
> > Have you followed the past discussions about this patch set? Basica=
lly
> > the *only* feedback I received on RFCv1 is that the fixed-link prop=
erty
> > sucks, and everybody (including the known Device Tree binding
> > maintainer Mark Rutland) suggested to not use the fixed-link mechan=
ism.
> > See http://article.gmane.org/gmane.linux.network/276932, where Mark
> > said:
> >=20
> > ""
> > I'm not sure grouping these values together is the best way of hand=
ling
> > this. It's rather opaque, and inflexible for future extension.
> > ""
> >=20
> > So, please DT maintainers, tell me what you want. I honestly don't =
care
> > whether fixed-link or a separate node is chosen. However, I do care
> > about being dragged around between two solutions just because the
> > former DT maintainer and the new DT maintainers do not agree.

I've been sleepy on this issue, which limits how much I can push. I'll
say one more thing on the issue (below) and then leave the decision up
to Mark. I trust him and he knows what he is doing.

> Since I would like to move forward so I can one day use that binding =
in a=20
> real-life product, I am going to go for Mark's side which happens to =
be how I=20
> want the binding to look like.
>=20
> Do we all agree that the new binding is just way better than the old =
one? In=20
> light of the recent unstable DT ABI discussion, we can still continue=
 parsing=20
> the old one for the sake of compatibility.

Regardless of what you want it to look like, does the old binding work
for your purposes? If yes then use it. The only valid reason for
creating a new binding is if the old one doesn't work for a specific
(not theoretical) use case.

g.
