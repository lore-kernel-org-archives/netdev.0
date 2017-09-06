From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 16:16:24 +0200
Message-ID: <20170906141624.GE11864@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
 <87y3pskk1p.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58708 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932284AbdIFOQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:16:27 -0400
Content-Disposition: inline
In-Reply-To: <87y3pskk1p.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > What i found is that the Marvell chips don't flood broadcast frames
> > between bridged ports. What appears to happen is there is a fdb miss,
> > so it gets forwarded to the CPU port for the host to deal with. The
> > software bridge when floods it out all ports of the bridge.
> 
> Do you have this issue on a single switch?

Yes. I have two boards with a single switch in my test setup. They
fail the broadcast tests in the same way as boards with multiple
switches.

> It should be done at the DSA level. DSA core must be the single entry
> point to handle all the switch logic, calling into (dumb) DSA drivers.
> If it is buried into a specific driver, we'll likely lose track of the
> problem and make it harder to maintain.

I think we need to wait and see what driver writers report their chips
are doing. If this is just a Marvell issue, we probably should fix it
in the Marvell driver only.

If i remember correctly, Woojung said he was seeing duplication of
broadcasts. So it could be the Microchip hardware is forwarding
broadcast in the hardware.

	  Andrew
