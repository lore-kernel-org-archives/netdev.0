From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Wed, 08 Sep 2010 17:59:15 -0400
Message-ID: <4C880733.5010909@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <871v95f2xv.fsf@deeprootsystems.com> <4C86F369.6040906@criticallink.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@deeprootsystems.com>,
	"tony@atomide.com" <tony@atomide.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Michael Williamson <michael.williamson@criticallink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42190 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756075Ab0IHV7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 17:59:20 -0400
In-Reply-To: <4C86F369.6040906@criticallink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mike,

[...]
> So I just pulled this to test it out on a da850 based board
> (mitydspl138), and I'm having some problems.  I'm hoping it's just
> operator error.

Probably not, considering that this series had not been tested on da8xx
platforms.  Thanks for jumping in!

> I have a TI TLK100PHP PHY at address 0x3.  The boot log shows:
> 
> [snip]
> davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
> davinci_mdio davinci_mdio.0: detected phy mask fffffff7
> davinci_mdio.0: probed
> davinci_mdio davinci_mdio.0: phy[3]: device 0:03, driver unknown
> [snip]

So far so good.  The MDIO code seems to have done its part and latched
on to the correct phy.  To answer your question from below, the "driver
unknown" implies that the generic phy driver has been attached to the
detected phy.

> and then in the init scripts, following udev population I get a 
> "Configuring network interfaces... "
> 
> and the boot process just hangs.

Not a peep from emac? Strange.

> I went back and did a menuconfig, I didn't see an option for TI PHY support, but
> shouldn't there be a "generic" PHY driver that defaults if one isn't matched?  I 
> do have TI DaVinci EMAC/MDIO/CPDMA support enabled under the Ethernet (10 or 100 Mbit).
> 
> Anyway, I've only looked at this for about 15 minutes, and I was hoping anyone might 
> point out something obvious.  If there are hints anyone might have for debugging, I'd
> appreciate them as well.  Or, if anyone has tested this with a da850 evm, that would 
> point me to a problem in the board file.

I spent some time today on testing this series on a da830 evm board
(sorry, couldn't manage to scrounge up a da850 platform).  In the
process, I have had to put in some fixes, particularly for the
phy-association piece.  You can preview these commits on my repo's
gitweb [1].

Cheers
Cyril.

1.
http://arago-project.org/git/people/?p=cyril/linux-tnetv107x.git;a=log;h=emac-cpdma-mdio-fixes
