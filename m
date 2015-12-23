From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Wed, 23 Dec 2015 23:33:03 +0100
Message-ID: <20151223223303.GD25485@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <567B07CB.5080308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49115 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932823AbbLWWdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 17:33:06 -0500
Content-Disposition: inline
In-Reply-To: <567B07CB.5080308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 12:44:59PM -0800, Florian Fainelli wrote:
> Hi Andrew,
>=20
> Le 23/12/2015 04:56, Andrew Lunn a =E9crit :
> > As noted in Documentation/networking/dsa/dsa.txt, the current DSA
> > architecture has a few architecture problems:
> >=20
> > DSA is implemented as a DSA platform device driver which is conveni=
ent because
> > it will register the entire DSA switch tree attached to a master ne=
twork device
> > in one-shot, facilitating the device creation and simplifying the d=
evice driver
> > model a bit, this comes however with a number of limitations:
> >=20
> > - building DSA and its switch drivers as modules is currently not w=
orking
> > - the device driver parenting does not necessarily reflect the orig=
inal
> >   bus/device the switch can be created from
> > - supporting non-MDIO and non-MMIO (platform) switches is not possi=
ble
> >=20
> > This RFC patchset attempts to address this. It allows the switch
> > device to be true Linux devices, and use of the device component
> > framework to bind the switch devices to the DSA framework, similar =
to
> > the way GPU engines are bound to the master GPU driver. The drivers
> > are now modules, which can be loaded and unloaded. Reloading howeve=
r
> > currently causes an Opps, hence RFC.
> >=20
> > The code remains backwards compatible with the old binding, and add=
s a
> > new property to facilitate the component framework. Switch drivers =
get
> > there own binding, allowing them to be probed independent of DSA.

Hi Florian

> Well, sort of, and that is the part that gives me mixed feelings righ=
t
> now. Your conversion of the bcm_sf2 driver, although it looks good an=
d
> gets us where we should go, still poses a major problem for my platfo=
rms
> where a wrong DTB is frozen (at least for some time).

I hope i've not broken backwards compatibility, so your old DT blobs
should still work. If they don't work, we should debug why.

> I still think that using a 'dsa' platform device and having to bind
> other drivers to it is just an artifact and relic from the original
> design that we do not necessarily need anymore but with the component=
s
> framework, it seems to get us in a better shape.

I don't really see how we can do without a dsa platform driver. We
need something that brings together all the switches in a cluster. We
need somewhere which holds the information about how these switches
are connected together and connected to the host.

    Andrew
