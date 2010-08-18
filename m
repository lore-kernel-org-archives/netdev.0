From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Wed, 18 Aug 2010 17:02:03 +0200
Message-ID: <201008181702.03384.arnd@arndb.de>
References: <cover.1281956490.git.richard.cochran@omicron.at> <201008171336.29375.arnd@arndb.de> <20100818140440.GA22655@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: john stultz <johnstul@us.ibm.com>, linuxppc-dev@lists.ozlabs.org,
	Rodolfo Giometti <giometti@linux.it>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:63675 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833Ab0HRPBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 11:01:54 -0400
In-Reply-To: <20100818140440.GA22655@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 18 August 2010, Richard Cochran wrote:
> On Tue, Aug 17, 2010 at 01:36:29PM +0200, Arnd Bergmann wrote:
> > On Tuesday 17 August 2010, Richard Cochran wrote:
> > > I've been looking at offering the PTP clock as a posix clock, and it
> > > is not as hard as I first thought. The PTP clock or clocks just have
> > > to be registered as one of the posix_clocks[MAX_CLOCKS] in
> > > posix-timers.c.
> > 
> > Ok sounds good.
> 
> I've been working turning the PTP stuff into syscalls, but here is a
> little issue I ran into. The PTP clock layer wants to call the PPS
> code via pps_register_source(), but the PPS can be compiled as a
> module. Since the PTP layer is now offering syscalls, it must always
> be present in the kernel. So I need to make sure that the PPS is
> either absent entirely or staticly linked in.
> 
> How can I do this?

You might want to use callbacks for these system calls that you
can register to at module load time, like it is done for the
existing syscalls.

The simpler way (e.g. for testing) is using Kconfig dependencies, like

config PTP
	bool "IEEE 1588 Precision Time Protocol"

config PPS
	tristate "Pulse per Second"
	depends on PTP || !PTP

The depends statement is a way of expressing that when PTP is enabled,
PPS cannot be a module, while it may be a module if PTP is disabled.

	Arnd
