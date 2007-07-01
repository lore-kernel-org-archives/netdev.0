From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sun, 1 Jul 2007 12:23:16 +0200
Message-ID: <200707011223.17235.mb@bu3sch.de>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <200707010024.40649.mb@bu3sch.de> <20070630231734.GF2553@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-1?q?T=F6r=F6k_Edvin?= <edwintorok@gmail.com>,
	zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:34523
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960AbXGAKYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 06:24:04 -0400
In-Reply-To: <20070630231734.GF2553@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 July 2007 01:17:34 Lennert Buytenhek wrote:
> More or less.  You can't add the resistances like that, since the
> bus isolation chip buffers the IDSEL signal, but it is correct that
> if the host's IDSEL resistor is larger than a certain value, the
> combination of the resistive coupling of IDSEL plus the extra buffer
> in the isolator might be causing the IDSEL input on the 'guest' PCI
> board to assert too late (or not assert at all), causing config
> accesses to fail.
> 
> (This also depends on the specific 'guest' PCI board used, as you
> noted, due to differing IDSEL trace lengths/capacitances and input
> pin capacitances on different PCI boards.  Also, it might work at
> 33 MHz but not work at 66 MHz, etc.)

It doesn't work on any of my boards :(

> If you feel adventurous, you could try to hack around this by
> figuring out which AD[31:16] line this PCI slot's IDSEL line is
> resistively coupled to (depends on the slot), and then adding
> another parallel resistor on the board itself to make the bus
> isolator's input buffer charge faster.  Note that this does
> increase the load on that specific AD[] line, which might cause
> other funny effects.

Well, but how to find out to which address line it's connected to?
Pretty hard to follow the PCB traces, especially since it's
multilayered.

-- 
Greetings Michael.
