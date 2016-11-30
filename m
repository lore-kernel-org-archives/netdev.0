From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 14:52:57 +0100
Message-ID: <20161130135257.GC18716@lunn.ch>
References: <1480495831.3563.135.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34996 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757037AbcK3NxA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:53:00 -0500
Content-Disposition: inline
In-Reply-To: <1480495831.3563.135.camel@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 08:50:34AM +0000, Joakim Tjernlund wrote:
> I am trying to wrap my head around these two "devices" and have a hard time telling them apart.
> We are looking att adding a faily large switch(over PCIe) to our board and from what I can tell
> switchdev is the new way to do it but DSA is still there. Is it possible to just list
> how they differ?

Hi Joakim

If the interface you use to send frames from the host to the switch is
PCIe, you probably want to use switchdev directly.

DSA devices all use a host Ethernet interface to send frames to the
switch. DSA sits under switchdev, and effectively provides a lot of
the common stuff needed for implementing switch drivers of this
sort. It creates the slave interfaces, links the MAC to the PHY, has
one uniform device tree binding which all DSA switches have, deals
with encapsulation/decapsulating frames sent over the master device,
etc.

	    Andrew
