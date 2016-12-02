From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next 4/4] net: dsa: mv88e6xxx: Refactor CPU and DSA
 port setup
Date: Fri, 2 Dec 2016 22:18:06 +0100
Message-ID: <20161202211806.GF30716@lunn.ch>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch>
 <1480701779-30633-5-git-send-email-andrew@lunn.ch>
 <87h96mcadj.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38245 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750842AbcLBVSK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 16:18:10 -0500
Content-Disposition: inline
In-Reply-To: <87h96mcadj.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The port's EgressMode, FrameMode and EtherType are really tied together
> to compose the mode of the port.

Setting the EtherType is somewhat separate. It is only needed on ports
using EDSA. And that can only happen on a CPU port. Humm, actually, i
set it when i should not. But putting this in a wrapper actually hides
this.

> Could you add an helper in chip.c like:
> 
>     static int mv88e6xxx_set_port_mode(struct mv88e6xxx_chip *chip, int port,
>                                        enum mv88e6xxx_frame_mode frame_mode,
>                                        u16 egress_mode, bool egress_unknown,
>                                        u16 ethertype)
>     {
>         int err;
> 
>         if (chip->info->ops->port_set_frame_mode) {
>             err = chip->info->ops->port_set_frame_mode(chip, port, frame_mode);
>             if (err)
>                 return err;
>         }

Ignoring that it is not implemented here is wrong. It must be
implemented, or the device is not going to work. It is a question of,
do we want an oops, or return an error code.

New version coming.

    Andrew
