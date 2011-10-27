From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/2 v3] net/smsc911x: Add regulator support
Date: Thu, 27 Oct 2011 16:46:38 +0100
Message-ID: <20111027154638.GA16946@sirena.org.uk>
References: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com>
 <CAJaTeTrzFwxsn22U-NHQ8iCiaUM+mj8PyicavR-DN0HgE08ZEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJaTeTrzFwxsn22U-NHQ8iCiaUM+mj8PyicavR-DN0HgE08ZEQ@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2011 at 03:21:47PM +0200, Mike Frysinger wrote:

> my gut reaction: smsc911x is working just fine without regulator
> support for many people, so why do we suddenly need to make it a
> requirement ?  this is a fairly small amount of code, so adding a
> smsc911x Kconfig symbol to control the regulator support seems like
> overkill.  only other option would be to change the patch to not make
> missing regulators non-fatal.  so i'd probably lean towards the latter
> (and it sounds like you changed this with earlier versions).

The regulator API contains a series of generic facilities for stubbing
itself out when not in use - there's no need for individual drivers to
worry about this stuff, they should just rely on the framework.  The
main one at the minute is REGULATOR_DUMMY which does what you suggest
and makes regulator_get() never fail.
