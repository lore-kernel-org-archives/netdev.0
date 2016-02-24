From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: custom ioctl-based interface to control LED in networking (was
 Re: [PATCHv2 09/10] rfkill: Userspace control for airplane mode)
Date: Wed, 24 Feb 2016 14:31:33 +0100
Message-ID: <1456320693.2050.30.camel@sipsolutions.net>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
	 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
	 <20160223204525.GC16961@amd> <1456260914.9910.34.camel@sipsolutions.net>
	 <20160223214501.GA22501@amd> <1456304509.2050.15.camel@sipsolutions.net>
	 <20160224104611.GB31302@amd> <1456311697.2050.23.camel@sipsolutions.net>
	 <20160224121420.GA5627@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org, j.anaszewski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	linux-leds-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160224121420.GA5627@amd>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-02-24 at 13:14 +0100, Pavel Machek wrote:
>=C2=A0
> Why would it need to? It could look at default triggers for the led
> if it really wanted to.

And then it needs to change them; if anything goes wrong error recovery
is practically impossible since the trigger information is lost
forever.

> > I'm sure you'd also not like to see 2**7 triggers implemented in
> > rfkill
> > to cover all the possibilities.
>=20
> Are all the possibilities useful? I assumed about 2 are. If you need
> 2**7 of them, LED triggers can have parameters.

It's not my position to decide which combinations some system
integrator or userspace developer might find useful.

Even when we add parameters to a trigger (I don't see a generic way to
do that, but please do enlighten me), you're now ignoring the issue of
the userspace controlled GSM modem...

> > Really what you have here is a concept of "airplane mode", and that
> > concept is specific to the rfkill subsystem. This happens to affect
> > mostly an LED trigger, today, but as a concept it's something that
> > *should* be managed within the rfkill subsystem.
>=20
> How is that concept used outside the LEDs? What semantics does
> "airplane mode" have? You tried to explain "airplane mode" is not
> well defined up in this thread...

I'd say it's well-defined for any given set of system software, so if
e.g. NetworkManager decides to define it one way, and connman another
way, there's a definition but the kernel need not interfere with it.

> > > Besides, the series really should have been Cc-ed to LED
> > > people, too.
> >=20
> > That's simply unreasonable, you're essentially saying that any user
> > of any kernel infrastructure should be Cc'ed to the implementer of
> > that infrastructure... 9/10 patches in this series aren't even LED
> > specific,
>=20
> I'm not saying that. I'm saying that LED maintainers should be Cced,
> to keep the interfaces consistent.

I pretty much have to read it that way, since the LED API is in no way
impacted by these changes. Here's a new trigger, with some magic inner
working. No impact on the LED API.

johannes
