From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 10:42:52 +0100
Message-ID: <20170328094252.GV7909@n2100.armlinux.org.uk>
References: <1490662190.3177.91.camel@kernel.crashing.org>
 <20170328010940.GG25549@lunn.ch>
 <1490668137.3177.98.camel@kernel.crashing.org>
 <1490669734.3177.100.camel@au1.ibm.com>
 <20170328041405.045FEB206B@b01ledav03.gho.pok.ibm.com>
 <1490678238.3177.102.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:52898 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752770AbdC1JoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 05:44:05 -0400
Content-Disposition: inline
In-Reply-To: <1490678238.3177.102.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 04:17:18PM +1100, Benjamin Herrenschmidt wrote:
> I added a printk inside genphy_read_status() to inspect the result
> of the negociation, and this is what I read:
> 
> lpa=c1e1 lpagb=3800 adv=de1 common_adv=1e1 common_adv_gb=800
> 
> As you can see, LPA doesn't have the Pause bits. *However* it does
> have bit 0x80 which can mean ADVERTISE_100HALF, but according to
> our own mii.h can also mean ADVERTISE_1000XPAUSE. Similarily it 
> has bit 0x100 which can mean ADVERTISE_100FULL but also can mean
> ADVERTISE_1000XPSE_ASYM.

The 1000X definitions are for 1000BaseX (fiber), not for 1000BaseT
(copper).

I have a working setup here with gigabit pause.  The pause bits come
from bits 11 and 10, just like for older copper PHYs.  Your link
parter is indicating that it has no pause capability.  That means
you can't use pause.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
