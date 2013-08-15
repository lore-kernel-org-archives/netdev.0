From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Thu, 15 Aug 2013 09:42:27 -0700
Message-ID: <20130815164227.GC15688@kroah.com>
References: <20130813174814.GE4098@kroah.com>
 <20130814091946.2643a124@mitra.spranger.biz>
 <20130814163311.GB7208@kroah.com>
 <20130815084221.3339142f@mitra.spranger.biz>
 <20130815065936.GA13320@kroah.com>
 <20130815092753.5a23810b@mitra.spranger.biz>
 <20130815080901.GC7080@kroah.com>
 <520C8EC9.6040603@linutronix.de>
 <20130815155508.GA14792@kroah.com>
 <520CFBE0.5070006@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benedikt Spranger <b.spranger@linutronix.de>,
	netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:39002 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757941Ab3HOQkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 12:40:52 -0400
Content-Disposition: inline
In-Reply-To: <520CFBE0.5070006@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 06:03:44PM +0200, Sebastian Andrzej Siewior wrote:
> On 08/15/2013 05:55 PM, Greg Kroah-Hartman wrote:
> > But that's a "platform" device, for a resource that is described as not
> > going away.
> > 
> > If this is really a mfd device, then make your uio driver a mfd driver,
> > not a platform driver for a resource that isn't under your control.
> 
> As you described it later yourself: You have the same problem if you
> manually unbind the platform_device from the driver while the device
> node is open.

No, at that point in time the remove function of the uio driver should
be called, and you can invalidate everything then.  Or the driver should
be doing that, odds are, it needs to be fixed because no one checks for
that :)

> >> If you look now at uio_write() then you will notice that it will
> >> deference idev->info->irqcontrol but once the device is gone the memory
> >> starting at info is gone, not to mention the code behind irqcontrol.
> > 
> > It sounds like the wrong uio driver is binding to this device, fix the
> > uio driver and you should be fine, right?
> 
> For this to happen you would need a refcount in uio-core which learns
> that the device is gone and does not invoke any callbacks because the
> device is gone. Something like you have in USB where you return 0 on
> reads from ttyUSB after someone pulled the cable.

That happens because we invalidate the filehandle in the tty layer by
tearing everything down in the usb serial driver.  And yes, uio also
needs to do the same thing, if it doesn't already.

thanks,

greg k-h
