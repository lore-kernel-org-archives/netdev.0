From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: ibm_newemac: Don't start autonegotiation when disabled in BMCR (genmii)
Date: Tue, 19 Jul 2011 13:59:57 +0200
Message-ID: <201107191359.57421.sr@denx.de>
References: <1311072604-24840-1-git-send-email-sr@denx.de> <1311075322.25044.418.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:31982 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362Ab1GSMAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 08:00:04 -0400
In-Reply-To: <1311075322.25044.418.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Tuesday 19 July 2011 13:35:22 Benjamin Herrenschmidt wrote:
> On Tue, 2011-07-19 at 12:50 +0200, Stefan Roese wrote:
> > As noticed on a custom 440GX board using the Micrel KSZ8041 PHY in
> > fiber mode, a strapped fixed PHY configuration will currently restart
> > the autonegotiation. This patch checks the BMCR_ANENABLE bit and
> > skips this autonegotiation if its disabled.
> 
> Won't that just break aneg on everything else ?
> 
> IE, most other PHYs rely on ANENABLE being set further down this same
> function (especially if the FW doesn't do it but even then, we may reset
> PHYs along the way etc...)

If aneg is enabled for a PHY (e.g. not strapped to fixed configuration), I 
don't see how this patch will change the current aneg behaviour. Perhaps I'm 
missing something, but I tested this on some boards with aneg enabled (Sequoia 
etc). And I didn't notice any problems.
 
> This is something that really a case where the device-tree should
> indicate that aneg shall not be performed and from there don't call
> setup_aneg at all.

I feel that this BMCR_ANENABLE bit should be evaluated, but I have no strong 
preference here. If you prefer that this should be handled via a new dt 
property (phy-aneg = "disabled" ?), I can implement it this way. Just let me 
know.

Thanks,
Stefan
