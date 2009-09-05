From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Fri, 4 Sep 2009 21:49:03 -0700
Message-ID: <20090904214903.49e5a361@nehalam>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	johannes@sipsolutions.net
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42290 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750861AbZIEEt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 00:49:56 -0400
In-Reply-To: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Sep 2009 00:08:19 -0700
Marcel Holtmann <marcel@holtmann.org> wrote:

> The Ethernet framing is used for a lot of devices these days. Most
> prominent are WiFi and WiMAX based devices. However for userspace
> application it is important to classify these devices correctly and
> not only see them as Ethernet devices. The daemons like HAL, DeviceKit
> or even NetworkManager with udev support tries to do the classification
> in userspace with a lot trickery and extra system calls. This is not
> good and actually reaches its limitations. Especially since the kernel
> does know the type of the Ethernet device it is pretty stupid.
> 
> To solve this problem the underlying device type needs to be set and
> then the value will be exported as DEVTYPE via uevents and available
> within udev.
> 
>   # cat /sys/class/net/wlan0/uevent
>   DEVTYPE=wlan
>   INTERFACE=wlan0
>   IFINDEX=5
> 

The problem with your idea is that there is only a nebulous definition of
what is a Wifi device, and what is a WiMAX device etc.  What userspace should be looking
for is "does device XXX support API yyy?" and if it supports API
yyy then I it can be configured that way. 

There already is some information in sysfs like /sys/class/net/XXX/type
which gives the hardware type (ARPHRD_ETHER, etc).  Why not a better version
of something like this that provides "can do FOO" interface?

Doing a several system calls (open/read/close) per device is not a big
issue. Even an android phone can do open/read/close in less than a millisecond
I bet.

