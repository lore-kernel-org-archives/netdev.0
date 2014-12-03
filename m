From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Wed, 3 Dec 2014 11:14:52 -0500
Message-ID: <20141203161452.GD2896@tuxdriver.com>
References: <20141201111125.GA11974@localhost.localdomain>
 <1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
 <20141201221023.79ffb40d@wiggum>
 <20141202200129.GA4580@crion89>
 <20141202211211.7e08b935@wiggum>
 <547E3BF5.5060201@lwfinger.net>
 <20141203161855.50951aa8@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Andrey Skvortsov <andrej.skvortzov@gmail.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Gary.Zambrano@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Michael =?iso-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141203161855.50951aa8@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 03, 2014 at 04:18:55PM +0100, Michael B=FCsch wrote:
> On Tue, 02 Dec 2014 16:23:49 -0600
> Larry Finger <Larry.Finger@lwfinger.net> wrote:
>=20
> > On 12/02/2014 02:12 PM, Michael B=FCsch wrote:
> > > On Tue, 2 Dec 2014 23:01:29 +0300
> > > Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
> > >
> > >> On Mon, Dec 01, 2014 at 10:10:23PM +0100, Michael B=FCsch wrote:
> > >>> On Mon,  1 Dec 2014 23:46:38 +0300
> > >>> Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
> > >>>
> > >>>> Wake On Lan was not working on laptop DELL Vostro 1500.
> > >>>> If WOL was turned on, BCM4401 was powered up in suspend mode. =
LEDs blinked.
> > >>>> But the laptop could not be woken up with the Magic Packet. Th=
e reason for
> > >>>> that was that PCIE was not enabled as a system wakeup source a=
nd
> > >>>> therefore the host PCI bridge was not powered up in suspend mo=
de.
> > >>>> PCIE was not enabled in suspend by PM because no child devices=
 were
> > >>>> registered as wakeup source during suspend process.
> > >>>> On laptop BCM4401 is connected through the SSB bus, that is co=
nnected to the
> > >>>> PCI-Express bus. SSB and B44 did not use standard PM wakeup fu=
nctions
> > >>>> and did not forward wakeup settings to their parents.
> > >>>> To fix that B44 driver enables PM wakeup and registers new wak=
eup source
> > >>>> using device_set_wakeup_enable(). Wakeup is automatically repo=
rted to the parent SSB
> > >>>> bus via power.wakeup_path. SSB bus enables wakeup for the pare=
nt PCI bridge, if there is any
> > >>>> child devices with enabled wakeup functionality. All other ste=
ps are
> > >>>> done by PM core code.
> > >>>
> > >>> Thanks, this looks good.
> > >>> I assume you tested this (I currently don't have a device to te=
st this).
> > >>
> > >> Sure, I've tested it. WOL from suspend is working and after resu=
me from hibernate Ethernet is working too.
> > >
> > > That sounds good, indeed.
> > > I'd still prefer, if someone with b43 (wireless) would test it, t=
oo.
> >=20
> > I did a partial test with my PowerBook G4. With the patch installed=
, it would=20
> > both suspend and hibernate, but WOL would be impossible. This compu=
ter uses a=20
> > PCMCIA version of the BCM4318, and power is turned off to the PCMCI=
A card when=20
> > suspended or hibernating.
>=20
> Thanks for testing.
>=20
> John, can you take this one? Or do we need to split the b44 part out?
> I added my Signed-off.

Um, sure...3.19 is OK I presume?

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
