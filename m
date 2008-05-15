From: Jean Delvare <khali@linux-fr.org>
Subject: Re: SFC driver implements its own I2C support
Date: Thu, 15 May 2008 14:39:54 +0200
Message-ID: <20080515143954.15bc4170@hyperion.delvare>
References: <20080513103325.1ab317cf@hyperion.delvare>
	<20080514215818.GH28241@solarflare.com>
	<20080515112416.55ffd328@hyperion.delvare>
	<Pine.LNX.4.62.0805151258150.13626@dolphin.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	Linux I2C <i2c@lm-sensors.org>,
	linux-net-drivers@solarflare.com
To: Michael Brown <mbrown@fensystems.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:26525 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbYEOMkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 08:40:16 -0400
In-Reply-To: <Pine.LNX.4.62.0805151258150.13626@dolphin.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008 13:04:50 +0100 (BST), Michael Brown wrote:
> On Thu, 15 May 2008, Jean Delvare wrote:
> > > Last time I checked (i.e. when I originally wrote this bit of the 
> > > code), the kernel's own i2c layer didn't provide any clean way for 
> > > kernel code (rather than user code) to access i2c devices.
> > 
> > I am not sure what Michael was referring to exactly, but access to i2c 
> > devices from the kernel has been supported pretty much forever. Maybe he 
> > really meant access to hardware monitoring devices? For these indeed 
> > there is a standard user-space interface (through sysfs) but no standard 
> > in-kernel access; mainly because there has never been a clear need for 
> > one. Again, if you need something, please discuss it on the relevant 
> > mailing lists and we'll find a way for you to use the standard 
> > subsystems rather than reimplementing them for your own use.
> 
> From memory (and this may be inaccurate), it looked as though the i2c 
> subsystem code for EEPROM access was contained within 
> drivers/i2c/chips/eeprom.c, and that this code provided an interface for 
> userspace to access the EEPROM contents, but no interface for kernel code 
> to do so.

This is correct and is still the case. This eeprom driver is a simple
way to export small EEPROM data to user-space in read-only mode. It
should not be considered as a real driver for EEPROM access. For that,
please see the upcoming at24c driver:
  http://lists.lm-sensors.org/pipermail/i2c/2008-April/003307.html
Apparently there are a lot of people interested in this so I will have
to find some time to finally review and merge the driver if it is ready
to go. Help with testing and review is welcome.

> I think there may also have been issues with the fact that the i2c system 
> allows for failures on the shutdown path (e.g. i2c_detach_client() can 
> return a failure), which becomes awkward to handle when you are in the 
> middle of a shutdown path that is not allowed to fail (e.g. a
> pci_driver->remove method).

This part of the code has been reworked completely. That being said, I
see that the i2c_driver remove method returns an int not void, so it
can still fail. There doesn't seem to be a common behavior in this
respect amongst subsystems, some allow the remove method to fail and
others don't. If you think that the i2c subsystem should not let remove
methods fail, we can discuss this. But most likely, the error code is
purely informative so it doesn't really matter if we return it or void.

-- 
Jean Delvare
