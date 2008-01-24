From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH UCC TDM 1/3 Updated] Platform changes for UCC TDM driver for MPC8323eRDB. Also includes related QE changes and dts entries.
Date: Thu, 24 Jan 2008 19:23:45 +0300
Message-ID: <20080124162345.GA27359@localhost.localdomain>
References: <Pine.LNX.4.64.0801241553270.4984@linux121> <20080124154804.GA22178@localhost.localdomain> <4798B4F3.2010101@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Poonam_Aggrwal-b10812 <b10812@freescale.com>,
	kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	ashish.kalra@freescale.com
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:4681 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753181AbYAXQYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 11:24:01 -0500
Content-Disposition: inline
In-Reply-To: <4798B4F3.2010101@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2008 at 09:55:31AM -0600, Timur Tabi wrote:
> Anton Vorontsov wrote:
> 
> >Can we not introduce new pio-maps in the device trees? There
> >were debates regarding this, and if I understood everything
> >correctly, pio-maps considered as a bad taste. Better
> >do bunch of par_io_config_pin() in the board file. Better
> >yet fixup the firmware (u-boot) to set up dedicated pins
> >correctly.
> 
> I'm on the fence with respect to pio-maps vs. par_io_config_pin() calls.  
> The problem is that the configuration of these pins is board-specific, but 
> pins are used by devices.  A device driver can't call par_io_config_pin(), 
> because the calls are different depending on which SoC and which UCC you're 
> using.  The platform code can't call par_io_config_pin(), because that 
> configuration depends on which drivers are loaded.

Are you saying that TDM is sharing same pins with the other QE device,
and we can choose to use/not use some device depending on which driver
is loaded? I think this particular board and patch isn't that case.

Even if someday there will be the case when drivers are mutually
exclusive, i.e. presence of some driver should trigger pins
reconfiguration, then anyway this should be handled differently.

That is, we should not _register_ two mutually exclusive devices
in the first place, so drivers will not probe them. That's board
setup code authority, and pins configuration still should happen
there.

[ Irrelevant to UCCs and this particular case: lately I've
  encountered one interesting case of Par IO usage. FHCI USB needs
  switching between pin's dedicated functions and GPIO functions.
  So, firstly it is using pins as dedicated, and later (at the bus
  reset) driver turns them to act as GPIOs. This is still handled
  without pio-map though, via gpios = <> property for that driver. ]

> In other words, the pin configurations are dependent on the UCC 
> configurations, and the UCC configurations are stored in the device tree.  
> So it makes sense to put the pin configurations in the device tree, too.

In that particular case UCC configuration is static, for every UCC.
So, we can set up all pins in the firmware/board file.

Please correct me if I'm wrong.

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
