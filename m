From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Fri, 14 Feb 2014 13:53:21 -0800
Message-ID: <CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
	<B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
	<CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
	<6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
	<CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
	<FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw>
	<CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com>
	<65183A93811745C58958ECBAD0B8E00F@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:44631 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbaBNVxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:53:21 -0500
Received: by mail-ob0-f175.google.com with SMTP id wn1so14539327obc.34
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 13:53:21 -0800 (PST)
In-Reply-To: <65183A93811745C58958ECBAD0B8E00F@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 13, 2014 at 7:13 PM, hayeswang <hayeswang@realtek.com> wrote:
> Grant Grundler [mailto:grundler@google.com]
>> Sent: Friday, February 14, 2014 6:23 AM
>> To: hayeswang
>> Cc: Inki Yoo; netdev; David Miller
>> Subject: Re: RTL8153 fails to get link after applying
>> c7de7dec2 to 3.8 kernel
> [...]
>> That makes sense. How can I check that?
>
> The simple way is to see the led on the device to check the linking
> with the cable attatched before any driver is loaded. Normally, I
> would see the linking before running the OS when I plug the dangle
> and then power on the PC. If you couldn't see the led on the device,
> you could check the one on the switch.

The device has no activity/link state LEDs...but I have the switch
sitting on my desk (8-port Netgear) that I connect it to.

>> Which "configuration" are you referring to?
>
> Configuration 1. That has more power saving features.
>
>> Something like this?
>> /sys/devices/12110000.usb/usb3/3-2/bConfigurationValue
>
> Yes. Modify the value from 2 to 1.

This value was 1 by default on the ARM systems where I don't have
r815x driver and r8152 is claiming the device. I previously tried to
set this value to 1 and I'm wondering if that value will now "stick"
until I reboot. I will add c7de7dec patch again and see what it says.

Testing on x86 (below) shows the value as 2. The x86 system is still
running a kernel that doesn't have either r8152 or r815x driver
enabled.

Bus 002 Device 002: ID 0bda:8153 Realtek Semiconductor Corp.

localhost 2-1 # cat manufacturer product bConfigurationValue
Realtek
USB 10/100/1000 LAN
2

I've swapped the devices between the two systems and each system
reports the same values. I'll update the x86 system to run a new
kernel (with the c7de7dec patch) and see if what it reports is
different.

...
> My udev rule (50-usb-realtek-net.rules) likes the following.
>
> ACTION!="add", GOTO="usb_realtek_net_end"
> SUBSYSTEM!="usb", GOTO="usb_realtek_net_end"
> ENV{DEVTYPE}!="usb_device", GOTO="usb_realtek_net_end"
> ATTR{idVendor}=="0bda", ATTR{idProduct}=="8153", ATTR{bConfigurationValue}!="1", ATTR{bConfigurationValue}="1"
> LABEL="usb_realtek_net_end"

Thanks for including that.  Would have taken a while for me to figure it out.

cheers,
grant
