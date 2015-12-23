From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 25/28] Documentation: DSA: Describe how probe of DSA
 and switches work.
Date: Wed, 23 Dec 2015 23:53:22 +0100
Message-ID: <20151223225322.GE25485@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-26-git-send-email-andrew@lunn.ch>
 <567B089C.7030108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49126 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536AbbLWWxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 17:53:25 -0500
Content-Disposition: inline
In-Reply-To: <567B089C.7030108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 12:48:28PM -0800, Florian Fainelli wrote:
> Le 23/12/2015 04:56, Andrew Lunn a =E9crit :
> > With the introduction of switches as linux devices and the use of t=
he
> > component framework, probing has become more complex. Add some
> > documentation.
> >=20
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> >  Documentation/networking/dsa/dsa.txt | 48 ++++++++++++++++++++++++=
++++++++++++
> >  1 file changed, 48 insertions(+)
> >=20
> > diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/n=
etworking/dsa/dsa.txt
> > index aa9c1f9313cd..376afa135a81 100644
> > --- a/Documentation/networking/dsa/dsa.txt
> > +++ b/Documentation/networking/dsa/dsa.txt
> > @@ -398,6 +398,54 @@ Switch configuration
> >    on the management interface and "hardcode"/"force" this MAC addr=
ess for the
> >    CPU/management interface as an optimization
> > =20
> > +Call flow
> > +---------
> > +
> > +With the ability for switch devices to be true linux devices, the =
call
> > +flow is somewhat complex. The component framework is used to link =
the
> > +dsa framework as the master, with switch devices, as slaves.
> > +
> > +A switch device should add itself as a component in its probe
> > +function.
> > +
> > +The DSA framework can either be configured using a platform_data
> > +structure or from the device tree. If device tree is being used, t=
he
> > +dsa framework probe function will allocate a platform_data structu=
re,
> > +and populate it using the device tree, via the dsa_of_probe()
> > +function.  Within the DSA device tree, switch devices are represen=
ted
> > +by a phandle to the switch device. These phandles are saved into t=
he
> > +platform data so that when switch slaves register themselves, they=
 can
> > +be correctly positioned in the DSA cluster.
>=20
> Humm, I guess I am still not clear on that, in a DT-only system, do I
> still need to get the DSA platform device to be probed via DT, along
> with references to the switches I want? If that is the case, that see=
ms
> a little awkward, could not we probe the individual switches, and see=
 if
> they need DSA instead? Or is that how the component framework works,
> just being a bit confused here.

The component framework needs one master device and a number of slave
devices. The master device effectively gives the framework a list of
slave devices it needs. When the slave devices probe they register
with the component framework. The master then asks the framework if
its slaves are present, and if not returns -EPRODE_DEFERS and tries
again later.

So the dsa platform device is the master, and the switch devices are
the slaves.

It sounds like you want to 'optimise' for a DSA cluster consisting of
a single switch, throwing away the D in DSA. Now the SF2 is a bit
'odd'. Since it is embedded in the SoC, you cannot have multiple of
them in a cluster. So such an optimization could make sense for the
SF2. But can we do this without adding too more complexity?

     Andrew
