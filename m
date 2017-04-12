From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
Date: Wed, 12 Apr 2017 18:54:23 +0200
Message-ID: <20170412165423.GA16424@lunn.ch>
References: <CAJ+vNU1UG2EeJSTStT_BJ+RiRe4a8YwfRgnE6DsRghTLetq_rg@mail.gmail.com>
 <20170407160915.GF23415@lunn.ch>
 <CAJ+vNU2itJEBMLNz--w9FOis_jMHW9c+UPwU6wh+ma59kbeswA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Lucas Stach <l.stach@pengutronix.de>,
        Fugang Duan <fugang.duan@nxp.com>,
        Koen Vandeputte <koen.vandeputte@ncentric.com>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56800 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754582AbdDLQyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 12:54:25 -0400
Content-Disposition: inline
In-Reply-To: <CAJ+vNU2itJEBMLNz--w9FOis_jMHW9c+UPwU6wh+ma59kbeswA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 09:15:11AM -0700, Tim Harvey wrote:
> On Fri, Apr 7, 2017 at 9:09 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Fri, Apr 07, 2017 at 07:47:17AM -0700, Tim Harvey wrote:
> >> Greetings,
> >>
> >> I've had a couple of users report that they are getting occasional
> >> link drops when using IMX6 FEC on our boards which are using a Marvell
> >> 88E1510 PHY:
> >>
> >> [ 9348.474418] fec 2188000.ethernet eth0: MDIO read timeout
> >> [ 9350.478804] fec 2188000.ethernet eth0: Link is Down
> >>
> >> If they bring the interface back up it works fine.
> >>
> >> The most recent version of Linux they have tested and seen this on is
> >> v4.9 with CONFIG_MARVELL_PHY=y
> >>
> >> Has anyone else run into this or know what the issue could be? Should
> >> there be any retries at the MDIO level or above?
> >
> > Hi Tim
> >
> > MDIO is assumed to be reliable. It failing is bad.
> >
> > However, ETIMEOUT is interesting. The MDIO protocol has no flow
> > control. There is no way for the PHY to delay replying.
> >
> > I would suggest you look at the power management code. What i have
> > seen with the FEC, when using switches attached to the FEC, is that if
> > the clocks are turned off, you get ETIMEOUT from MDIO.
> >
> >     Andrew
> 
> Andrew,
> 
> Thanks for the reply. Your talking about suspend/resume power
> management right? The users reporting this were not using
> suspend/resume.

Hi Tim

As Fabio just pointed out, i was meaning run time power management.

It used to be, that the FEC driver powered up the clocks when the
interface was opened. But when using a switch connected to the MDIO
bus, you can be using the MDIO bus while the interface is still
closed. And that did not work. So the runtime PM was extended to the
MDIO bus.

It could be there is a race condition in this code somewhere.

   Andrew
