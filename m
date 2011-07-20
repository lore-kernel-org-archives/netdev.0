From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: ibm_newemac: Don't start autonegotiation when disabled in BMCR (genmii)
Date: Wed, 20 Jul 2011 09:18:34 +0200
Message-ID: <201107200918.34873.sr@denx.de>
References: <1311072604-24840-1-git-send-email-sr@denx.de> <201107191359.57421.sr@denx.de> <1311078570.25044.421.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:54936 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab1GTHSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 03:18:44 -0400
In-Reply-To: <1311078570.25044.421.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 19 July 2011 14:29:30 Benjamin Herrenschmidt wrote:
> > I feel that this BMCR_ANENABLE bit should be evaluated, but I have no
> > strong preference here. If you prefer that this should be handled via a
> > new dt property (phy-aneg = "disabled" ?), I can implement it this way.
> > Just let me know.
> 
> Don't we already have some bindings for PHY with a fixed setting ? I
> don't remember off hand, we need to dbl check.

The only related PHY property I found is "fixed-link" used in fs_enet-main.c. 
None in the emac driver. Here the description for "fixed-link":

Documentation/devicetree/bindings/net/fsl-tsec-phy.txt:

  - fixed-link : <a b c d e> where a is emulated phy id - choose any,
    but unique to the all specified fixed-links, b is duplex - 0 half,
    1 full, c is link speed - d#10/d#100/d#1000, d is pause - 0 no
    pause, 1 pause, e is asym_pause - 0 no asym_pause, 1 asym_pause.

But what I really want to achieve, is to skip auto-negotiation (use the 
strapped configuration). And not to define this fixed configuration (again) in 
the device-tree. So I would prefer something like phy-aneg = "disabled".

What do you think?

Thanks,
Stefan
