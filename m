From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Thu, 13 Feb 2014 10:55:15 +0800
Message-ID: <FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com><B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw><CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com><6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw> <CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Inki Yoo' <inky.yoo@samsung.com>,
	'netdev' <netdev@vger.kernel.org>,
	'David Miller' <davem@davemloft.net>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:38521 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaBMCzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 21:55:24 -0500
In-Reply-To: <CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Grant Grundler [mailto:grundler@google.com] 
> Sent: Thursday, February 13, 2014 7:58 AM
> To: hayeswang
> Cc: Inki Yoo; netdev; David Miller
> Subject: Re: RTL8153 fails to get link after applying 
> c7de7dec2 to 3.8 kernel
[...]
> > # ethtool -i eth0
> > driver: r815x
> > version: 22-Aug-2005
> 
> BTW, can you please update the version number to match adding 
> RTL8153 support?
> Makes life easier for anyone maintaining older kernels.

The information is from ecm driver, maybe cdc_ether or usbnet. I don't
think I could modify it.

> > Is your dangle from Samsung?
> 
> It's labeled "Realtek USB 3.0 Gigabit Ethernet" externally. I'm not
> sure if we got these from Samsung or directly from RealTek.
> 
> What's notable is this device has no link or activity LEDs visible.
> Normally I'd expect those near the RJ45 port.
> 
> Also no MAC address or serial number or anything to further identify
> the devices. just the "rectangular black plastic" enclosure with a
> silver sticker carrying the Realtek logo + text.

According to the information from our FAE about the dangles for samsung,
the default values of some device power are disabled or off. I don't know
the history about this. However, it would cause the dangle no link, because
the ecm driver wouldn't enable them. That is, the dangle couldn't use the
ECM mode. I think you should create a udev rule to change the configuration
to 1 when the dangle is plugged. Then, it could load the vendor mode driver.

> > I would ask our PM to check if there is any difference 
> between our devices.
> > Maybe it is not the driver issue.
> 
> I don't think it's a r8152 or r815x driver issue either. It's much
> more likely related to chromeos-3.8 USB NET patches not matching 3.14
> kernel behaviors.

I don't think so. The reason is as above. Change the configuration of the
device to 1 (vendor mode) is what you have to do.
 
Best Regards,
Hayes
