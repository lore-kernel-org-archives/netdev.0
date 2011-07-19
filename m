From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: ibm_newemac: Don't start autonegotiation when
 disabled in BMCR (genmii)
Date: Tue, 19 Jul 2011 22:29:30 +1000
Message-ID: <1311078570.25044.421.camel@pasglop>
References: <1311072604-24840-1-git-send-email-sr@denx.de>
	 <1311075322.25044.418.camel@pasglop>  <201107191359.57421.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36426 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749Ab1GSM3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 08:29:40 -0400
In-Reply-To: <201107191359.57421.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-19 at 13:59 +0200, Stefan Roese wrote:
> Hi Ben,
> 
> On Tuesday 19 July 2011 13:35:22 Benjamin Herrenschmidt wrote:
> > On Tue, 2011-07-19 at 12:50 +0200, Stefan Roese wrote:
> > > As noticed on a custom 440GX board using the Micrel KSZ8041 PHY in
> > > fiber mode, a strapped fixed PHY configuration will currently restart
> > > the autonegotiation. This patch checks the BMCR_ANENABLE bit and
> > > skips this autonegotiation if its disabled.
> > 
> > Won't that just break aneg on everything else ?
> > 
> > IE, most other PHYs rely on ANENABLE being set further down this same
> > function (especially if the FW doesn't do it but even then, we may reset
> > PHYs along the way etc...)
> 
> If aneg is enabled for a PHY (e.g. not strapped to fixed configuration), I 
> don't see how this patch will change the current aneg behaviour. Perhaps I'm 
> missing something, but I tested this on some boards with aneg enabled (Sequoia 
> etc). And I didn't notice any problems.

But is aneg always enabled via straps ? The whole point of this function
is that aneg can be enabled or disabled via the ethtool API (thus
overriding whatever strapping)... I may be missing something but this
patch looks like it would break this no ?

> > This is something that really a case where the device-tree should
> > indicate that aneg shall not be performed and from there don't call
> > setup_aneg at all.
> 
> I feel that this BMCR_ANENABLE bit should be evaluated, but I have no strong 
> preference here. If you prefer that this should be handled via a new dt 
> property (phy-aneg = "disabled" ?), I can implement it this way. Just let me 
> know.

Don't we already have some bindings for PHY with a fixed setting ? I
don't remember off hand, we need to dbl check.

I don't like looking at BMCR because BCMR is a -control- register,
something that we can (and will) whack with anything ourselves, which
can be reset or reconfigured and I have learned to never trust board
straps :-)

Cheers,
Ben.


