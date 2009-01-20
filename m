From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 3/6] arm: convert pcm037 platform to use smsc911x
Date: Tue, 20 Jan 2009 16:29:51 +0100
Message-ID: <20090120152951.GB21134@pengutronix.de>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com> <1232458114-10997-2-git-send-email-steve.glendinning@smsc.com> <1232458114-10997-3-git-send-email-steve.glendinning@smsc.com> <1232458114-10997-4-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42625 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589AbZATP34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 10:29:56 -0500
Content-Disposition: inline
In-Reply-To: <1232458114-10997-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just gave it a try on our pcm037 board and it turns out that it
doesn't work.

The reason for this is not the driver, it's just that the hardware
designers got the direction of the phy detect pin wrong. The pcm037 uses
an internal phy, but the detection pin is pulled high :(

The old driver worked around this by falling back to the internal phy
when no valid phy id is detected. The new driver lacks this fallback.

Instead of falling back we could also introduce a
SMSC911X_FORCE_INTERNAL_PHY flag.

What do you think?

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
