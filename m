From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Sat, 05 Sep 2009 07:55:58 +0200
Message-ID: <1252130158.27694.13.camel@violet>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
	 <20090904214903.49e5a361@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	johannes@sipsolutions.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54345 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbZIEFz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 01:55:58 -0400
In-Reply-To: <20090904214903.49e5a361@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

> > The Ethernet framing is used for a lot of devices these days. Most
> > prominent are WiFi and WiMAX based devices. However for userspace
> > application it is important to classify these devices correctly and
> > not only see them as Ethernet devices. The daemons like HAL, DeviceKit
> > or even NetworkManager with udev support tries to do the classification
> > in userspace with a lot trickery and extra system calls. This is not
> > good and actually reaches its limitations. Especially since the kernel
> > does know the type of the Ethernet device it is pretty stupid.
> > 
> > To solve this problem the underlying device type needs to be set and
> > then the value will be exported as DEVTYPE via uevents and available
> > within udev.
> > 
> >   # cat /sys/class/net/wlan0/uevent
> >   DEVTYPE=wlan
> >   INTERFACE=wlan0
> >   IFINDEX=5
> > 
> 
> The problem with your idea is that there is only a nebulous definition of
> what is a Wifi device, and what is a WiMAX device etc.  What userspace should be looking
> for is "does device XXX support API yyy?" and if it supports API
> yyy then I it can be configured that way. 

We don't need that. We just need to know what technology is behind that
Ethernet device. Otherwise we have no real starting point.

> There already is some information in sysfs like /sys/class/net/XXX/type
> which gives the hardware type (ARPHRD_ETHER, etc).  Why not a better version
> of something like this that provides "can do FOO" interface?

that was my initial idea, but I couldn't come up with something good.
And the DEVTYPE from struct device is a standard way of exposing such
information. Actually subsystem like SCSI, USB, Bluetooth etc. use that
already. So why not do the same for Ethernet based devices.

> Doing a several system calls (open/read/close) per device is not a big
> issue. Even an android phone can do open/read/close in less than a millisecond
> I bet.

It is not only the system calls that userspace has to do. There is no
central place for this stuff and why should be do it all if the kernel
already has all the details.

Regards

Marcel


