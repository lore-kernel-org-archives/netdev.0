From: Ben Hutchings <bhutchings@solarflare.com>
Subject: PHC device sharing between PCI functions
Date: Mon, 1 Jul 2013 17:56:08 +0100
Message-ID: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20844 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab3GAQ4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 12:56:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Future Solarflare NICs may allow multiple PCI functions to make use of a
PTP hardware clock, but without a separate clock per function (probably
only one per controller).

I understand that shared PTP hardware clocks already exist, but they
usually have an independent existence as a separate PCI or platform
device.  In this case the clock would be accessible through any of the
PCI functions that also have a net device.

Options I see are:

1. Instantiate a clock only for the first function.  But that would
preclude making the clock available within multiple VMs and their host.

2. Keep track of controllers in the driver, and instantiate a clock
device for each function we see that is part of a controller we haven't
yet seen.  However, if that first function is subsequently passed-
through to a VM from its host, the host loses the clock (it can't be
reparented).

3. Keep track of controllers in the driver, instantiate a 'platform
device' for each of them, and instantiate a clock for each of them.
This is a little weird, as it wouldn't have any obvious association to
the PCI device hierarchy.  But it would let us control the lifetime of
the clock devices independently of any one function.

I prefer option 3 as I dislike introducing special cases, but I would be
interested to hear your (or other people's) opinion on this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
