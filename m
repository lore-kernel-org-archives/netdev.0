From: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Subject: RE: SMSC 8720a/MDIO/PHY help.
Date: Fri, 15 Apr 2011 15:53:41 -0500
Message-ID: <9AC3F0E75060224C8BBC5BA2DDC8853A1FB11170@EXV1.corp.adtran.com>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com><1302729564.2742.28.camel@malcolm><9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8D4@EXV1.corp.adtran.com> <BANLkTik7xeMnx0S2m0easY0hVT_UmomjzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <michael@riesch.at>, <netdev@vger.kernel.org>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c12o145.mxlogic.net ([208.65.145.78]:54272 "EHLO
	p02c12o145.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470Ab1DOUyC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:54:02 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <BANLkTik7xeMnx0S2m0easY0hVT_UmomjzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Andy Fleming
> Sent: Friday, April 15, 2011 3:30 PM
> To: ANDY KENNEDY
> Cc: michael@riesch.at; netdev@vger.kernel.org
> Subject: Re: SMSC 8720a/MDIO/PHY help.
>=20
> On Wed, Apr 13, 2011 at 4:38 PM, ANDY KENNEDY
> <ANDY.KENNEDY@adtran.com> wrote:
> >> -----Original Message-----
> >> From: Michael Riesch [mailto:michael@riesch.at]
> >> Sent: Wednesday, April 13, 2011 4:19 PM
> >> To: netdev@vger.kernel.org
> >> Cc: ANDY KENNEDY
> >> Subject: Re: SMSC 8720a/MDIO/PHY help.
> >>
> >>
> >> > If you have an idea of something for me to try, I'd love to
> >> entertain
> >> > it.
> >>
> >> I am rather new to PHYLIB, but these are my ideas:
> >>
> >> =A01) make sure phy_connect is executed (AFIAK called by MDIO bus
> >> driver)
> >
> > Going through the phy.txt doc under Documentation/networking:
> > PHY Abstraction Layer
> > (Updated 2008-04-08)
> > though it may be a bit out-of-date, I did see what you are
> talking about. =A0What I'm hung up on at the moment is the behavior
> of adjust_link(). =A0It appears that I only need to start the queues,
> though I don't know.
> >
> >>
> >> =A02) maybe you need to call phy_start / phy_stop (AFAIK from the
> PHY
> >> driver's open / close function)
> >
> > Currently, when I do this I only get the call to adjust_link()
> over and over again.
>=20
>=20
> ...this means that the state machine is running.  The PHY is
> polling
> every couple seconds to report the current state. It calls
> adjust_link() to keep the net_device up-to-date on that state. What
> other behavior are you expecting to see?

Well, you see I was expecting it to be up and running at that point (to=
 be able to assign an IP, pass traffic, etc) -- but that is due to igno=
rance of (1) network device drivers, (2) PHY device drivers, (3) MDIO b=
us drivers, (4) General level 2 networking, (5) ;) get the point?

See, I'm totally new to networking (at this level).  Device drivers, ye=
s, but not networking.

Though, after Michael's e-mails, I have discovered that I have to
1) Make the MDIO bus work
2) Establish communications with the MDIO driver (in this case smsc.c u=
nder net/phy)
3) Make all my NDO required functions for controlling the "real" networ=
k device -- I was unaware that the PHY _WASN'T_ the network device.
4) Call phy_connect_direct (so I don't trash the already existent smsc.=
c as before stated)
5) Finally, after the NDO functions are written, register the NDO with =
the networking layer of the Kernel.

One thing I have done wrong (realized AFTER depending upon the work I'v=
e done) is that I should have split out the MDIO and the network device=
=2E =20

Now, where is the document that explains all this.  The PHY document is=
 very informative, however, if you don't know that a PHY is NOT a netwo=
rk device, you're kinda outta luck.  Even Wiki reports a PHY as the Phy=
sical Link layer of the OSI model.  Which, again, doesn't tell the igno=
rant much.

I have a bit more knowledge now, however, and I think I've about got my=
 network device up (that would be I'm only 80% ignorant now ;).

Andy
