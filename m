From: Oliver Neukum <oneukum@suse.de>
Subject: explaining the math behind the buffering done in USB network drivers
Date: Thu, 08 Nov 2012 18:35:07 +0100
Message-ID: <1544921.F1ezT4niGW@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: Robert Bradley <robert.bradley1@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Jim Gettys <jg@freedesktop.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38199 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266Ab2KHRfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 12:35:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

it is probably necessary to state the limitations of USB to understand
why we buffer as much data as we buffer. Basically the schedule on
the USB bus is set in stone for a period of 1ms(full speed). This means that a driver
has to have submitted to USB core enough data to fill _2_ such periods
at all times. Thus the schedule for the current period is filled up and the
host controller can seamlessly switch to the next period.
In addition the driver has to be ready to provide the data for the next period
as soon as one period is done.

Thus conceptually for USB we do tripple-buffering.
Few drivers actually express this logic internally. One usually calculates
a rough approximation, but this is the logic behind the thing.

	Regards
		Oliver
