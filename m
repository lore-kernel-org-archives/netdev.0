From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 3/6] arm: convert pcm037 platform to use smsc911x
Date: Wed, 21 Jan 2009 15:38:37 +0100
Message-ID: <20090121143837.GF21134@pengutronix.de>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com> <1232458114-10997-2-git-send-email-steve.glendinning@smsc.com> <1232458114-10997-3-git-send-email-steve.glendinning@smsc.com> <1232458114-10997-4-git-send-email-steve.glendinning@smsc.com> <20090120152951.GB21134@pengutronix.de> <20090121105813.GA22213@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44714 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbZAUOiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 09:38:50 -0500
Content-Disposition: inline
In-Reply-To: <20090121105813.GA22213@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 10:58:15AM +0000, Mark Brown wrote:
> On Tue, Jan 20, 2009 at 04:29:51PM +0100, Sascha Hauer wrote:
> 
> > The reason for this is not the driver, it's just that the hardware
> > designers got the direction of the phy detect pin wrong. The pcm037 uses
> > an internal phy, but the detection pin is pulled high :(
> 
> A brief survey of boards I have here suggests that this failure is not
> unique.
> 
> > The old driver worked around this by falling back to the internal phy
> > when no valid phy id is detected. The new driver lacks this fallback.
> 
> > Instead of falling back we could also introduce a
> > SMSC911X_FORCE_INTERNAL_PHY flag.
> 
> If we have the explicit flag in the platform data my concern would be
> that it would get reported back to the hardware designers and they might
> fix the board in subsequent revisions.  That'd cause issues if the
> revision of the board weren't identifiable from software (which wouldn't
> surprise me at all).

That's why I haven't told the hardware designers yet ;)

Anyway, a FORCE_INTERNAL_PHY flag would still do the right thing. At
least as long the hardware designers do not decide to put an external
phy in the next hardware revision.
If we decide to add such a flag we should add an FORCE_EXTERNAL_PHY
aswell for the sake of completeness.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
