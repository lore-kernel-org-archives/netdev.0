From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: Driver build-testing (was: [PATCH] net: dm9000: Fix build)
Date: Mon, 18 Apr 2011 08:28:25 -0700
Message-ID: <20110418082825.86a21574.rdunlap@xenotime.net>
References: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com>
	<20110418111203.GB18324@rere.qmqm.pl>
	<20110418122522.GC9462@sirena.org.uk>
	<20110418145102.GA2555@rere.qmqm.pl>
	<20110418075508.f7b14f43.rdunlap@xenotime.net>
	<20110418151729.GA4721@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	netdev@vger.kernel.org
To: Micha? Miros?aw <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy2-pub.bluehost.com ([67.222.39.60]:58921 "HELO
	oproxy2-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752285Ab1DRP2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 11:28:32 -0400
In-Reply-To: <20110418151729.GA4721@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2011 17:17:29 +0200 Micha? Miros?aw wrote:

> On Mon, Apr 18, 2011 at 07:55:08AM -0700, Randy Dunlap wrote:
> > On Mon, 18 Apr 2011 16:51:02 +0200 Micha? Miros?aw wrote:
> > 
> > > On Mon, Apr 18, 2011 at 01:25:22PM +0100, Mark Brown wrote:
> > > > On Mon, Apr 18, 2011 at 01:12:03PM +0200, Micha? Miros?aw wrote:
> > > > > This brings the issue of build testing effectiveness. In current code
> > > > > there is no configuration that makes all drivers build. I would like
> > > > > to see something like 'make brokenconfig' that would allow most of
> > > > > the code to be built, and not necessarily working. Maybe someone has
> > > > > an idea how to implement that?
> > > > For the drivers that genuinely are rather platform specific this tends
> > > > to fail very badly as you need headers that only come along with the
> > > > architecture.
> > > > 
> > > > In the case of DM9000 if it fails to build on your platform then the
> > > > driver is just buggy - looking at the Kconfig I rather suspect that the
> > > > dependency on architectures should just be removed.
> > > I wonder if allyesconfig/allmodconfig is supposed to include code that's
> > > known not to work for a particular architecture.
> > all*config just use whatever is in all of the various Kconfig* files.
> > If they say "depends on $somearch", then so be it.  If not, then the
> > remaining dependencies are used.
> 
> Yes, I know how it works. I just wonder if removing those dependencies so
> that all drivers (even if known not to work) are built on all*config
> is acceptable. Or maybe there should be a config like 'disable all drivers
> that are known to build but not to work on this arch'?

AFAIK, it's always the case that we prefer not to have
	depends on $somearch
for drivers, but the reality is that lots of them do depend on $ARCH
for header files etc., so they are listed that way.  There's not much
that we can do about that.  I don't think that removing those dependencies
is acceptable.  OTOH, it may be acceptable to enable CONFIG_BROKEN so that
the drivers that depend on BROKEN can try to be built.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
