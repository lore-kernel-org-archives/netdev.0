From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 0/7] phylib MMD accessor cleanups
Date: Sun, 19 Mar 2017 18:01:29 +0100
Message-ID: <20170319170129.GB15440@lunn.ch>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53056 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751490AbdCSRCR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Mar 2017 13:02:17 -0400
Content-Disposition: inline
In-Reply-To: <20170319105943.GR21222@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 19, 2017 at 10:59:44AM +0000, Russell King - ARM Linux wrote:
> Hi,
> 
> This series cleans up the phylib MMD accessors.  We have two accessors
> at present, phy_(read|write)_mmd() and phy_(read|write)_mmd_indirect()
> 
> The _indirect methods access the MMD registers via a clause 22 phy,
> whereas the non-_indirect methods acess via clause 45 accesses.
> 
> Current PHY-independent parts of phylib (such as EEE) access the MMD
> registers via the _indirect methods, which is no good if you have a
> clause 45 PHY that doesn't respond to clause 22 accesses.
> 
> In order to make these features available, we need to rework these
> accessors such that they can access the MMD registers using a method
> dependent on the clause that the PHY conforms with.
> 
> This series of patches does exactly that - we merge the functionality
> of the indirect accesses into the clause 45 accessors, and use these
> exclusively to access MMD registers.  Internally, the new clause
> independent MMD accessors indirect via the PHY drivers read_mmd/write_mmd
> methods if present, otherwise fall back to using clause 45 accesses if
> the PHY is a clause 45 phy, or clause 22 indirect accesses if the PHY
> is clause 22.
> 
> Note: confusingly, phy_read_mmd_indirect() vs phy_read_mmd() switches
> the order of prtad and devad, which means that converting between the
> two is not a simple matter of just replacing the function name.  Same
> applies for the write methods.

Hi Russell

This all looks good, apart from the one typo i spotted.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
