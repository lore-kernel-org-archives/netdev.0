From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [patch 3/9] natsemi: Add support for using MII port with no PHY
Date: Fri, 28 Apr 2006 14:01:39 +0100
Message-ID: <20060428130139.GA20068@sirena.org.uk>
References: <200604270932.k3R9W5lK025315@shell0.pdx.osdl.net> <445094F2.1060807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:17169 "EHLO
	cassiel.sirena.org.uk") by vger.kernel.org with ESMTP
	id S1030379AbWD1NYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 09:24:12 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <445094F2.1060807@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2006 at 05:54:58AM -0400, Jeff Garzik wrote:

> >Provide a module option which configures the natsemi driver to use the
> >external MII port on the chip but ignore any PHYs that may be attached to 
> >it. The link state will be left as it was when the driver started and can 

> The proper way to do this is via the force_media boolean flag found in 
> several net drivers.

I've had a look at several of the net drivers that implement this option
(e100, smc91x, starfire and the shared code in mii.c).  Unless I'm
misreading the code it looks like the effect of this option in those
drivers is to disable autonegotiation but still configure the PHY when
the NIC is configured.

That is a subset of what the patch does and isn't sufficient for the
hardware this patch targets: sometimes there may be a PHY visible on the
MII bus but with a different configuration to the natsemi or there may
be no PHY present at all.  In this case the code in the natsemi driver
that configures the PHY to match the configuration of the natsemi also
needs to be disabled.

It looks like I should implement a force_media option and redo this
patch to use that.

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
