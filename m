From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Fri, 14 Feb 2014 11:13:06 +0800
Message-ID: <65183A93811745C58958ECBAD0B8E00F@realtek.com.tw>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com><B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw><CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com><6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw><CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com><FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw> <CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Inki Yoo' <inky.yoo@samsung.com>,
	'netdev' <netdev@vger.kernel.org>,
	'David Miller' <davem@davemloft.net>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [60.250.210.242] ([60.250.210.242]:59128 "EHLO
	rtits2.realtek.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbaBNDNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 22:13:53 -0500
In-Reply-To: <CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler [mailto:grundler@google.com] 
> Sent: Friday, February 14, 2014 6:23 AM
> To: hayeswang
> Cc: Inki Yoo; netdev; David Miller
> Subject: Re: RTL8153 fails to get link after applying 
> c7de7dec2 to 3.8 kernel
[...]
> That makes sense. How can I check that?

The simple way is to see the led on the device to check the linking
with the cable attatched before any driver is loaded. Normally, I
would see the linking before running the OS when I plug the dangle
and then power on the PC. If you couldn't see the led on the device,
you could check the one on the switch.

> > I think you should create a udev rule to change the configuration
> > to 1 when the dangle is plugged. Then, it could load the 
> vendor mode driver.
> 
> Which "configuration" are you referring to?

Configuration 1. That has more power saving features.

> Something like this? 
> /sys/devices/12110000.usb/usb3/3-2/bConfigurationValue

Yes. Modify the value from 2 to 1.

> I'm happy to try any command line you give me.
> 
> If that command works, I can write the udev rule for future testing
> with these devices.

My udev rule (50-usb-realtek-net.rules) likes the following.

ACTION!="add", GOTO="usb_realtek_net_end"
SUBSYSTEM!="usb", GOTO="usb_realtek_net_end"
ENV{DEVTYPE}!="usb_device", GOTO="usb_realtek_net_end"
ATTR{idVendor}=="0bda", ATTR{idProduct}=="8153", ATTR{bConfigurationValue}!="1", ATTR{bConfigurationValue}="1"
LABEL="usb_realtek_net_end"
 
Best Regards,
Hayes
