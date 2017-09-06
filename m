From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 02:47:03 +0200
Message-ID: <20170906004703.GB27385@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58290 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753087AbdIFArO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 20:47:14 -0400
Content-Disposition: inline
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The third and last issue will be explained in a followup email.

Hi DSA hackers

So there is the third issue. It affects just DSA, but it possible
affects all DSA drivers.

This patchset broken broadcast with the Marvell drivers. It could
break broadcast on others drivers as well.

What i found is that the Marvell chips don't flood broadcast frames
between bridged ports. What appears to happen is there is a fdb miss,
so it gets forwarded to the CPU port for the host to deal with. The
software bridge when floods it out all ports of the bridge.

But the set offload_fwd_mark patch changes this. The software bridge
now assumes the hardware has already flooded broadcast out all ports
of the switch as needed. So it does not do any flooding itself. As a
result, on Marvell devices, broadcast packets don't get flooded at
all.

The issue can be fixed. I just need to add an mdb entry for the
broadcast address to each port of the bridge in the switch, and the
CPU port.  But i don't know at what level to do this.

Should this be done at the DSA level, or at the driver level?  Do any
chips do broadcast flooding in hardware already? Hence they currently
see broadcast duplication? If i add a broadcast mdb at the DSA level,
and the chip is already hard wired to flooding broadcast, is it going
to double flood?

	Andrew
