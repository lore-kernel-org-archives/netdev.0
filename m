From: Andy Whitcroft <apw@canonical.com>
Subject: "sky2: set VPD size" triggers card recognition failure
Date: Thu, 11 Jun 2009 13:29:42 +0100
Message-ID: <20090611122942.GA7554@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:34017 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757740AbZFKM3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 08:29:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have reports[1] of sky2 cards failing to be recognised with the latest
2.6.30-rc8 kernels.  We are seeing what appears to be failures to
obtains the chip id correctly:

    sky2 driver version 1.22
    sky2 0000:02:00.0: enabling device (0000 -> 0003)
    sky2 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
    sky2 0000:02:00.0: setting latency timer to 64
    sky2 0000:02:00.0: Can't set VPD size
    sky2 0000:02:00.0: unsupported chip type 0xff
    sky2 0000:02:00.0: PCI INT A disabled
    sky2: probe of 0000:02:00.0 failed with error -95

Based on the VPD size failure message we reverted just the commit below,
which restored the card:

    commit 3834507d0c5480a0f05486c2fb57ed18fd179a83
    Author: Stephen Hemminger <shemminger@vyatta.com>
    Date:   Tue Feb 3 11:27:30 2009 +0000

	sky2: set VPD size
	
	Read configuration register during probe and use it to size the
	available VPD. Move existing code using same register slightly
	earlier in probe handling.
	
	Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
	Signed-off-by: David S. Miller <davem@davemloft.net>

Steven, any thoughts?

-apw

[1] https://www.launchpad.net/bugs/384403
