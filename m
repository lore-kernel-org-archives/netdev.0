From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Software loopback with phy 88E1116R and marvell MV78100 gbe
Date: Thu, 23 Feb 2017 11:59:58 +0100
Message-ID: <20170223105958.GC14312@lunn.ch>
References: <CABmfJQYEqWzPtfieaym-4KhG5f0PBHNDQzuT0Uk_bz-2WC3zag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Paolo Minazzi <paolo.minazzi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49866 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750944AbdBWLAA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 06:00:00 -0500
Content-Disposition: inline
In-Reply-To: <CABmfJQYEqWzPtfieaym-4KhG5f0PBHNDQzuT0Uk_bz-2WC3zag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I tried to do the same things on 88E1116R, setting the but 14 of reg 0.
> But If I do it I lose the link, and the test program does not work.
> I tried to force the link in software, but seems the controller send
> packets but it is not able to receive them.
> Is possibile to do such a software loopback on 88E1116R ?

Hi Paolo

What you are talking about here is MAC loopback. Packets are looped
back at the MAC level. The copper side will be left idle, and so the
link will be lost. This explains why you are seeing link down..

What you might need to do is extend marvell_update_link() to check if
MAC loopback is happening, and if so, say the link is up.

But this is all a bit questionable. How are you setting the PHY into
loopback? I guess the rest of the stack has no idea this is happening,
in particular the phy state machine. What happens when it comes out of
loopback? How is autoneg kicked off.

You might want to think about the big picture, and how this can be
incorporated into ethtool, and phylib. MAC loopback is pretty much
standard, so you should be able to solve this for all PHYs, not just
Marvell.

	     Andrew
