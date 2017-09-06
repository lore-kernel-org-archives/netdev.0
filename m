From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 06 Sep 2017 09:56:18 -0400
Message-ID: <87y3pskk1p.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch> <20170906004703.GB27385@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54472 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932251AbdIFN7n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 09:59:43 -0400
In-Reply-To: <20170906004703.GB27385@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> So there is the third issue. It affects just DSA, but it possible
> affects all DSA drivers.
>
> This patchset broken broadcast with the Marvell drivers. It could
> break broadcast on others drivers as well.
>
> What i found is that the Marvell chips don't flood broadcast frames
> between bridged ports. What appears to happen is there is a fdb miss,
> so it gets forwarded to the CPU port for the host to deal with. The
> software bridge when floods it out all ports of the bridge.

Do you have this issue on a single switch?

I do expect FDB (not MDB) miss on a multi-chip fabric, not on a single
chip though.

> But the set offload_fwd_mark patch changes this. The software bridge
> now assumes the hardware has already flooded broadcast out all ports
> of the switch as needed. So it does not do any flooding itself. As a
> result, on Marvell devices, broadcast packets don't get flooded at
> all.
>
> The issue can be fixed. I just need to add an mdb entry for the
> broadcast address to each port of the bridge in the switch, and the
> CPU port.  But i don't know at what level to do this.
>
> Should this be done at the DSA level, or at the driver level?  Do any
> chips do broadcast flooding in hardware already? Hence they currently
> see broadcast duplication? If i add a broadcast mdb at the DSA level,
> and the chip is already hard wired to flooding broadcast, is it going
> to double flood?

It should be done at the DSA level. DSA core must be the single entry
point to handle all the switch logic, calling into (dumb) DSA drivers.
If it is buried into a specific driver, we'll likely lose track of the
problem and make it harder to maintain.


Thanks!

        Vivien
