From: Michael Brown <mbrown@fensystems.co.uk>
Subject: Re: SFC driver implements its own I2C support
Date: Thu, 15 May 2008 15:52:42 +0100 (BST)
Message-ID: <Pine.LNX.4.62.0805151551330.13626@dolphin.home>
References: <20080513103325.1ab317cf@hyperion.delvare> <20080514215818.GH28241@solarflare.com>
 <20080515112416.55ffd328@hyperion.delvare> <Pine.LNX.4.62.0805151258150.13626@dolphin.home>
 <20080515143954.15bc4170@hyperion.delvare>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	Linux I2C <i2c@lm-sensors.org>,
	linux-net-drivers@solarflare.com
To: Jean Delvare <khali@linux-fr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprocket.fensystems.co.uk ([212.13.204.53]:45031 "EHLO
	sprocket.fensystems.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbYEOOw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 10:52:58 -0400
In-Reply-To: <20080515143954.15bc4170@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008, Jean Delvare wrote:
> > I think there may also have been issues with the fact that the i2c 
> > system allows for failures on the shutdown path (e.g. 
> > i2c_detach_client() can return a failure), which becomes awkward to 
> > handle when you are in the middle of a shutdown path that is not 
> > allowed to fail (e.g. a pci_driver->remove method).
> 
> This part of the code has been reworked completely. That being said, I 
> see that the i2c_driver remove method returns an int not void, so it can 
> still fail. There doesn't seem to be a common behavior in this respect 
> amongst subsystems, some allow the remove method to fail and others 
> don't. If you think that the i2c subsystem should not let remove methods 
> fail, we can discuss this. But most likely, the error code is purely 
> informative so it doesn't really matter if we return it or void.

It does matter if the i2c remove failure indicates that data structures 
are still left linked in to various lists etc.

Michael
