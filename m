From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH 2/2 v3] net/smsc911x: Add regulator support
Date: Thu, 27 Oct 2011 22:59:14 +0200
Message-ID: <CAJaTeTpzFOdgqGH3vDWY8Mdx7zra8R9nUQYHgsEBfy_yGkEWOw@mail.gmail.com>
References: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com>
 <CAJaTeTrzFwxsn22U-NHQ8iCiaUM+mj8PyicavR-DN0HgE08ZEQ@mail.gmail.com> <20111027154638.GA16946@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@stericsson.com>,
	netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Tony Lindgren <tony@atomide.com>, linux-omap@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20111027154638.GA16946@sirena.org.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2011 at 17:46, Mark Brown wrote:
> On Thu, Oct 27, 2011 at 03:21:47PM +0200, Mike Frysinger wrote:
>> my gut reaction: smsc911x is working just fine without regulator
>> support for many people, so why do we suddenly need to make it a
>> requirement ? =A0this is a fairly small amount of code, so adding a
>> smsc911x Kconfig symbol to control the regulator support seems like
>> overkill. =A0only other option would be to change the patch to not m=
ake
>> missing regulators non-fatal. =A0so i'd probably lean towards the la=
tter
>> (and it sounds like you changed this with earlier versions).
>
> The regulator API contains a series of generic facilities for stubbin=
g
> itself out when not in use - there's no need for individual drivers t=
o
> worry about this stuff, they should just rely on the framework. =A0Th=
e
> main one at the minute is REGULATOR_DUMMY which does what you suggest
> and makes regulator_get() never fail.

i saw that !CONFIG_REGULATOR works great.  my concern is that these
boards don't define any regulators for smsc resources, so if
CONFIG_REGULATOR is enabled to test out unrelated daughter cards, i
don't want the network driver suddenly failing.  Linus' comments
suggest that this is what would happen unless each board file has its
smsc platform resources extended.  maybe i misunderstood what he was sa=
ying ?
-mike
