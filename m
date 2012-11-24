From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 8139cp TX stall, timeout, failed recovery
Date: Sat, 24 Nov 2012 22:33:48 +0100
Message-ID: <20121124213348.GA8313@electric-eye.fr.zoreil.com>
References: <1353782365.26346.266.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com, gilboad@gmail.com,
	jgarzik@redhat.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45751 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab2KXV5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2012 16:57:53 -0500
Content-Disposition: inline
In-Reply-To: <1353782365.26346.266.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> To reproduce this, I send a *large* flood of packets (ping -l 1000) from
> inside my network to the ADSL router. Its internal-facing interface is
> an 8139cp. It seems to work best if the packets are destined for the
> outside world over the ADSL lines, rather than the router itself. But
> it's hard to tell. I need between 10 and 30 runs of 'ping -l 1000
> $outside' before it happens. Or sometimes more...

Did you try pktgen as well ?

[...]
> Looking at it now... do we wrap around the Rx ring buffer at 28498.055
> and process some of the packets more than once? Or is the hardware
> genuinely keeping up with us as we suck out, descriptors 51-63, 0-63,
> and 0-39 again all off the same interrupt? Perhaps there lies the root
> of the problem?

Rx slots are always spaced by ~50 us, i.e. more than needed to get a 98 bytes
packets. I do not like the lack of barrier wrt opts2 and opts1 writes for rx
descriptors but it does nprobably not matter for your problem.

If the r8169 experience is any guide, cp_tx_timeout is too light. It should
imho match the init sequence more closely, especially wrt descriptor rings
addresses and CpCmd.

-- 
Ueimor
