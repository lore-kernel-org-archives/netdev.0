From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next 0/5] Interrupt support for mv88e6xxx
Date: Tue, 18 Oct 2016 14:51:38 -0400
Message-ID: <87r37dlccl.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34886 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932970AbcJRSvl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:51:41 -0400
In-Reply-To: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> This patchset add interrupt controller support to the MV88E6xxx.  This
> allows access to the interrupts the internal PHY generate. These
> interrupts can then be associated to a PHY device in the device tree
> and used by the PHY lib, rather than polling.
>
> Since interrupt handling needs to make MDIO bus accesses, threaded
> interrupts are used. The phylib needs to request the PHY interrupt
> using the threaded IRQ API. This in term allows some simplification to
> the code, in that the phylib interrupt handler can directly call
> phy_change(), rather than use a work queue. The work queue is however
> retained for the phy_mac_interrupt() call, which can be called in hard
> interrupt context.
>
> Since RFC v1:
>
> Keep phy_mac_interrupt() callable in hard IRQ context.
>
> The fix to trigger the phy state machine transitions on interrupts has
> already been submitted, so is dropped from here.
>
> Added back shared interrupts support.
>
>
> Andrew Lunn (5):
>   net: dsa: mv88e6xxx: Implement interrupt support.
>   net: phy: Use threaded IRQ, to allow IRQ from sleeping devices
>   net: phy: Threaded interrupts allow some simplification
>   net: phy: Use phy name when requesting the interrupt
>   arm: vf610: zii devel b: Add support for switch interrupts
>
>  .../devicetree/bindings/net/dsa/marvell.txt        |  21 +-
>  arch/arm/boot/dts/vf610-zii-dev-rev-b.dts          |  51 +++++
>  drivers/net/dsa/mv88e6xxx/chip.c                   | 248 ++++++++++++++++++++-
>  drivers/net/dsa/mv88e6xxx/global2.c                | 139 +++++++++++-
>  drivers/net/dsa/mv88e6xxx/global2.h                |  11 +
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  31 +++
>  drivers/net/phy/phy.c                              |  52 +++--
>  drivers/net/phy/phy_device.c                       |   2 +-
>  include/linux/phy.h                                |   5 +-
>  9 files changed, 522 insertions(+), 38 deletions(-)

mv88e6xxx_g1_* should've been moved to global1.c, I'll move them later.

For what it's worth:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
