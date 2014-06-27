From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH CFT 26/30] net: fec: clear receive interrupts before
	processing a packet
Date: Fri, 27 Jun 2014 16:40:57 +0100
Message-ID: <20140627154057.GN32514@n2100.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk> <E1X0Xxa-0001Ot-54@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45337 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753579AbaF0PlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:41:01 -0400
Content-Disposition: inline
In-Reply-To: <E1X0Xxa-0001Ot-54@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 04:21:06PM +0100, Russell King wrote:
> Clear any pending receive interrupt before we process a pending packet.
> This helps to avoid any spurious interrupts being raised after we have
> fully cleaned the receive ring, while still allowing an interrupt to be
> raised if we receive another packet.
> 
> The position of this is critical: we must do this prior to reading the
> next packet status to avoid potentially dropping an interrupt when a
> packet is still pending.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

While there is a better algorithm for this, in order to implement that,
I also need to have feedback from the transmit reaping whether any work
was done there.

I have elected to implement that after a patch which adds byte queue
limits to the transmit side (which is in my second half of patches)
otherwise I need to do quite a bit of time consuming patch shuffling
and fixing to get it into the first half (at the moment the two halves
are separated by a complete revert of Andy's work from the last window.
The point of this half is to reduce the number of patches I'm currently
carrying so I can sensibly sort out the second half.)

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
