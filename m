From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Thu, 15 Aug 2013 08:55:08 -0700
Message-ID: <20130815155508.GA14792@kroah.com>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
 <1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
 <20130813174814.GE4098@kroah.com>
 <20130814091946.2643a124@mitra.spranger.biz>
 <20130814163311.GB7208@kroah.com>
 <20130815084221.3339142f@mitra.spranger.biz>
 <20130815065936.GA13320@kroah.com>
 <20130815092753.5a23810b@mitra.spranger.biz>
 <20130815080901.GC7080@kroah.com>
 <520C8EC9.6040603@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benedikt Spranger <b.spranger@linutronix.de>,
	netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:36801 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331Ab3HOPxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 11:53:33 -0400
Content-Disposition: inline
In-Reply-To: <520C8EC9.6040603@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 10:18:17AM +0200, Sebastian Andrzej Siewior wrote:
> On 08/15/2013 10:09 AM, Greg Kroah-Hartman wrote:
> > Do you have a specific example of an in-tree UIO driver that has this
> > problem that I can look at to try to understand this better?
> 
> grep for "uio_pdrv" and you find a few devices in arm and sh tree. Each
> one is created once at boot time and never removed. With mfd the device
> can be removed.

But that's a "platform" device, for a resource that is described as not
going away.

If this is really a mfd device, then make your uio driver a mfd driver,
not a platform driver for a resource that isn't under your control.

> If you look now at uio_write() then you will notice that it will
> deference idev->info->irqcontrol but once the device is gone the memory
> starting at info is gone, not to mention the code behind irqcontrol.

It sounds like the wrong uio driver is binding to this device, fix the
uio driver and you should be fine, right?

A module reference count will not "save" you from a device going away,
only a code chunk going away.  That is why no other subsystem has this
type of thing.  If you dynamically remove the mfd device, but not remove
the module (i.e. through the sysfs files to do that), then you would
still have this same problem, right?

There's a reason the driver core doesn't deal with module reference
counts, it's not the proper thing for devices.  So I'm not willing to
add it to the UIO code either, as it's not the correct thing for it.

thanks,

greg k-h
