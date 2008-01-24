From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH UCC TDM 1/3 Updated] Platform changes for UCC TDM driver
 for MPC8323eRDB. Also includes related QE changes and dts entries.
Date: Thu, 24 Jan 2008 09:55:31 -0600
Message-ID: <4798B4F3.2010101@freescale.com>
References: <Pine.LNX.4.64.0801241553270.4984@linux121> <20080124154804.GA22178@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Poonam_Aggrwal-b10812 <b10812@freescale.com>,
	kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	ashish.kalra@freescale.com
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:36798 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbYAXP4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 10:56:11 -0500
In-Reply-To: <20080124154804.GA22178@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:

> Can we not introduce new pio-maps in the device trees? There
> were debates regarding this, and if I understood everything
> correctly, pio-maps considered as a bad taste. Better
> do bunch of par_io_config_pin() in the board file. Better
> yet fixup the firmware (u-boot) to set up dedicated pins
> correctly.

I'm on the fence with respect to pio-maps vs. par_io_config_pin() calls.  The 
problem is that the configuration of these pins is board-specific, but pins are 
used by devices.  A device driver can't call par_io_config_pin(), because the 
calls are different depending on which SoC and which UCC you're using.  The 
platform code can't call par_io_config_pin(), because that configuration depends 
on which drivers are loaded.

In other words, the pin configurations are dependent on the UCC configurations, 
and the UCC configurations are stored in the device tree.  So it makes sense to 
put the pin configurations in the device tree, too.

-- 
Timur Tabi
Linux kernel developer at Freescale
