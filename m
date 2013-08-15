From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate module
 unloading
Date: Thu, 15 Aug 2013 18:03:44 +0200
Message-ID: <520CFBE0.5070006@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de> <1376384922-8519-3-git-send-email-b.spranger@linutronix.de> <20130813174814.GE4098@kroah.com> <20130814091946.2643a124@mitra.spranger.biz> <20130814163311.GB7208@kroah.com> <20130815084221.3339142f@mitra.spranger.biz> <20130815065936.GA13320@kroah.com> <20130815092753.5a23810b@mitra.spranger.biz> <20130815080901.GC7080@kroah.com> <520C8EC9.6040603@linutronix.de> <20130815155508.GA14792@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benedikt Spranger <b.spranger@linutronix.de>,
	netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:35287 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab3HOQDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 12:03:47 -0400
In-Reply-To: <20130815155508.GA14792@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 05:55 PM, Greg Kroah-Hartman wrote:
> But that's a "platform" device, for a resource that is described as not
> going away.
> 
> If this is really a mfd device, then make your uio driver a mfd driver,
> not a platform driver for a resource that isn't under your control.

As you described it later yourself: You have the same problem if you
manually unbind the platform_device from the driver while the device
node is open.

>> If you look now at uio_write() then you will notice that it will
>> deference idev->info->irqcontrol but once the device is gone the memory
>> starting at info is gone, not to mention the code behind irqcontrol.
> 
> It sounds like the wrong uio driver is binding to this device, fix the
> uio driver and you should be fine, right?

For this to happen you would need a refcount in uio-core which learns
that the device is gone and does not invoke any callbacks because the
device is gone. Something like you have in USB where you return 0 on
reads from ttyUSB after someone pulled the cable.

> A module reference count will not "save" you from a device going away,
> only a code chunk going away.  That is why no other subsystem has this
> type of thing.  If you dynamically remove the mfd device, but not remove
> the module (i.e. through the sysfs files to do that), then you would
> still have this same problem, right?

Yes, I think so.

> There's a reason the driver core doesn't deal with module reference
> counts, it's not the proper thing for devices.  So I'm not willing to
> add it to the UIO code either, as it's not the correct thing for it.

okay.

> 
> thanks,
> 
> greg k-h

Sebastian
