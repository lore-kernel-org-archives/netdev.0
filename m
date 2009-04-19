From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [BUG] 2.6.30-rc broke ixp4xx_eth, firmware breakage?
Date: Sun, 19 Apr 2009 11:32:12 +0200
Message-ID: <18922.61340.630534.74677@pilspetsen.it.uu.se>
References: <200904182153.n3ILrP6j027453@pilspetsen.it.uu.se>
	<20090418.211820.197285479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikpe@it.uu.se, khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759295AbZDSJcs@vger.kernel.org>
In-Reply-To: <20090418.211820.197285479.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:
 > From: Mikael Pettersson <mikpe@it.uu.se>
 > Date: Sat, 18 Apr 2009 23:53:25 +0200 (MEST)
 > 
 > > The ixp4xx_eth driver for my IXP420 XScale box (Synology DS101)
 > > worked fine in kernel 2.6.29. Now trying to boot 2.6.30-rc2 I'm
 > > greeted with the following failure during init:
 > > 
 > > Bringing up interface eth0:  RTNETLINK answers: No such file or directory
 > > Failed to bring up eth0.
 > > [FAILED]
 > > 
 > > There's a fairly long (at least 10 seconds) delay between the 'Bringing up'
 > > message and the RTNETLINK error.
 > > 
 > > A diff between the 2.6.29 and 2.6.30-rc2 boot logs indicates that
 > > the firmware doesn't get loaded:
 > 
 > Please make sure CONFIG_FIRMWARE_IN_KERNEL is set in your
 > configuration if this driver is being built statically
 > into your kernel.

ixp4xx_eth is built as a module and I have CONFIG_FIRMWARE_IN_KERNEL unset.

 > Otherwise, if modular, make sure the firmware files get installed into
 > the correct location and are available in the filesystem when the
 > driver loads.

The firmware isn't shipped with the kernel but is something users have to
download from Intel, build, and install themselves; once installed they work
across kernel versions. The files reside in /lib/firmware/'s top-level
directory, and they are available since firmware loading (triggered by init's
attempt to up eth0) occurs after / has been mounted. My userspace uses oldish
firmware-aware hotplug since udev's too heavy-weight.

This all works with 2.6.29 and older 2.6.2x kernels.

I'll do a bisect.
