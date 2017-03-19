From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 0/7] phylib MMD accessor cleanups
Date: Sun, 19 Mar 2017 15:30:38 -0700
Message-ID: <0b44bbd9-2be9-85cb-1518-4e4ec36927e1@gmail.com>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:35148 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752143AbdCSWal (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 18:30:41 -0400
In-Reply-To: <20170319105943.GR21222@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/19/17 à 03:59, Russell King - ARM Linux a écrit :
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

LGTM:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Note: confusingly, phy_read_mmd_indirect() vs phy_read_mmd() switches
> the order of prtad and devad, which means that converting between the
> two is not a simple matter of just replacing the function name.  Same
> applies for the write methods.
> 
>  drivers/net/phy/Makefile      |   2 +-
>  drivers/net/phy/bcm-phy-lib.c |  12 ++---
>  drivers/net/phy/dp83867.c     |  25 +++++-----
>  drivers/net/phy/intel-xway.c  |  26 +++++-----
>  drivers/net/phy/micrel.c      |  13 +++--
>  drivers/net/phy/microchip.c   |   5 +-
>  drivers/net/phy/phy-core.c    | 101 ++++++++++++++++++++++++++++++++++++++
>  drivers/net/phy/phy.c         | 110 ++++--------------------------------------
>  drivers/net/phy/phy_device.c  |   4 +-
>  drivers/net/usb/lan78xx.c     |  10 ++--
>  include/linux/phy.h           |  80 +++++++++---------------------
>  11 files changed, 178 insertions(+), 210 deletions(-)
> 


-- 
Florian
