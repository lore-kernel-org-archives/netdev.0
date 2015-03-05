From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: smc91x: use run-time configuration on all ARM
 machines
Date: Thu, 5 Mar 2015 09:06:04 +0000
Message-ID: <20150305090604.GE8656@n2100.arm.linux.org.uk>
References: <2226303.iMQTNXSl1n@wuerfel>
 <20150228.125721.1605776377351425463.davem@davemloft.net>
 <55454365.1GsbtFBXGk@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linus.walleij@linaro.org, robert.jarzmik@free.fr
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:52048 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbCEJGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 04:06:19 -0500
Content-Disposition: inline
In-Reply-To: <55454365.1GsbtFBXGk@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 04, 2015 at 11:36:16PM +0100, Arnd Bergmann wrote:
> On Saturday 28 February 2015 12:57:21 David Miller wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> > Date: Wed, 25 Feb 2015 16:31:57 +0100
> > 
> > > The smc91x driver traditionally gets configured at compile-time
> > > for whichever hardware it runs on. This no longer works on
> > > ARM as we continue to move to building all-in-one kernels.
> > > 
> > > Most ARM configurations with this driver already use run-time
> > > configuration through DT or through platform_data, but a
> > > few have not been converted yet.
> > > 
> > > I've checked all ARM boards that use this driver in their
> > > legacy board files, and converted the ones that were using
> > > compile-time configuration in smc91x.h to behave like the
> > > other ones and provide the interrupt polarity along with
> > > the MMIO configuration (width, stride) at platform device
> > > creation time.
> > > 
> > > In particular, these combinations were previously selectable
> > > in Kconfig but in fact broken:
> > > 
> > > - sa1100 assabet plus pleb
> > > - msm combined with any other armv6/v7 platform
> > > - pxa-idp combined with any non-DMA pxa variant
> > > - LogicPD PXA270 combined with any other pxa
> > > - nomadik combined with any other armv4/v5 platform,
> > >   e.g. versatile.
> > > 
> > > None of these seem critical enough to warrant a backport
> > > to stable, but it would be nice to clean this up for good.
> > > 
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > 
> > Applied, thanks Arnd.
> > 
> 
> It seems my build testing went wrong and although I was building
> lots of kernels, it did not catch the obvious typos I introduced.
> 
> I'm deeply sorry about that, following up with a fix now (which
> was actually tested).

Maybe it would be better to wait for someone to actually build and
run the change on real hardware?  You know I have a neponset, which
is one of the platforms you've changed.

(I may not be able to do that for a while yet however... still
recovering post-op.)

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
