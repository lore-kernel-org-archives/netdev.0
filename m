From: Pavel Machek <pavel@ucw.cz>
Subject: Re: custom ioctl-based interface to control LED in networking (was
 Re: [PATCHv2 09/10] rfkill: Userspace control for airplane mode)
Date: Thu, 25 Feb 2016 10:06:36 +0100
Message-ID: <20160225090636.GA32652@amd>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
 <20160223204525.GC16961@amd>
 <1456260914.9910.34.camel@sipsolutions.net>
 <20160223214501.GA22501@amd>
 <1456304509.2050.15.camel@sipsolutions.net>
 <20160224104611.GB31302@amd>
 <1456311697.2050.23.camel@sipsolutions.net>
 <20160224121420.GA5627@amd>
 <1456320693.2050.30.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rpurdie@rpsys.net, j.anaszewski@samsung.com,
	linux-leds@vger.kernel.org,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456320693.2050.30.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 2016-02-24 14:31:33, Johannes Berg wrote:
> On Wed, 2016-02-24 at 13:14 +0100, Pavel Machek wrote:
> >=A0
> > Why would it need to? It could look at default triggers for the led
> > if it really wanted to.
>=20
> And then it needs to change them; if anything goes wrong error recove=
ry
> is practically impossible since the trigger information is lost
> forever.

Well, conventional way to solve this is to simply name the led
"acer::airplane"... that way it is persistent. We already do that for
display/keyboard backlights.

> It's not my position to decide which combinations some system
> integrator or userspace developer might find useful.
>=20
> Even when we add parameters to a trigger (I don't see a generic way t=
o
> do that, but please do enlighten me), you're now ignoring the issue o=
f
> the userspace controlled GSM modem...

Take a look at the blinking triggers.

> > > Really what you have here is a concept of "airplane mode", and th=
at
> > > concept is specific to the rfkill subsystem. This happens to affe=
ct
> > > mostly an LED trigger, today, but as a concept it's something tha=
t
> > > *should* be managed within the rfkill subsystem.
> >=20
> > How is that concept used outside the LEDs? What semantics does
> > "airplane mode" have? You tried to explain "airplane mode" is not
> > well defined up in this thread...
>=20
> I'd say it's well-defined for any given set of system software, so if
> e.g. NetworkManager decides to define it one way, and connman another
> way, there's a definition but the kernel need not interfere with it.

So... the LED changes meaning during boot? That's surely not a nice
solution.

So... you rather store bit in a kernel with unclear semantics,
explaining "oh I need to leave the flexibility to userland"? Sorry,
that's just ugly.

> > I'm not saying that. I'm saying that LED maintainers should be Cced=
,
> > to keep the interfaces consistent.
>=20
> I pretty much have to read it that way, since the LED API is in no wa=
y
> impacted by these changes. Here's a new trigger, with some magic inne=
r
> working. No impact on the LED API.

New LED trigger and new ioctl for LED control... not matching how LEDs
are normally controlled.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
