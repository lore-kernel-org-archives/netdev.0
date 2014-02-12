From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Wed, 12 Feb 2014 11:47:00 +0800
Message-ID: <6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com><B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw> <CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Inki Yoo' <inky.yoo@samsung.com>,
	'netdev' <netdev@vger.kernel.org>,
	'David Miller' <davem@davemloft.net>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58872 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaBLDrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 22:47:07 -0500
In-Reply-To: <CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Grant Grundler [mailto:grundler@google.com] 
> Sent: Wednesday, February 12, 2014 6:27 AM
> To: hayeswang
> Cc: Inki Yoo; netdev; David Miller
> Subject: Re: RTL8153 fails to get link after applying 
> c7de7dec2 to 3.8 kernel
[...]
> > I would test the RTL8153 again with kernel 3.14-RC2.
> 
> Ok - if it worked before...I expect it will continue to work for you.

It still works for me. The followings are some messages from Fedora 20 with kernel 3.14.rc2.

# uname -a
Linux fc20.localdomain 3.14.0-rc2 #1 SMP Tue Feb 11 12:36:32 CST 2014 x86_64 x86_64 x86_64 GNU/Linux

# dmesg | tail
[   95.967662] usb 9-1: new SuperSpeed USB device number 2 using xhci_hcd
[   95.984017] usb 9-1: New USB device found, idVendor=0bda, idProduct=8153
[   95.984022] usb 9-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[   95.984026] usb 9-1: Product: USB 10/100/1000 LAN
[   95.984030] usb 9-1: Manufacturer: Realtek
[   95.984033] usb 9-1: SerialNumber: 00E04C680022
[   96.011116] usbcore: registered new interface driver cdc_ether
[   96.020634] r815x 9-1:2.0 eth0: register 'r815x' at usb-0000:04:00.0-1, RTL8153 ECM Device, 00:e0:4c:68:00:22
[   96.021866] usbcore: registered new interface driver r815x

# lsusb -d 0bda:8153
Bus 009 Device 002: ID 0bda:8153 Realtek Semiconductor Corp. 

# ethtool -i eth0
driver: r815x
version: 22-Aug-2005
firmware-version: RTL8153 ECM Device
bus-info: usb-0000:04:00.0-1
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

# ethtool eth0
Settings for eth0:
	Supported ports: [ TP MII ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10baseT/Half 10baseT/Full 
	                                     100baseT/Half 100baseT/Full 
	                                     1000baseT/Half 1000baseT/Full 
	Link partner advertised pause frame use: Symmetric Receive-only
	Link partner advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: MII
	PHYAD: 32
	Transceiver: internal
	Auto-negotiation: on
	Current message level: 0x00000007 (7)
			       drv probe link
	Link detected: yes

# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.94.35  netmask 255.255.255.0  broadcast 192.168.94.255
        inet6 fe80::2e0:4cff:fe68:22  prefixlen 64  scopeid 0x20<link>
        ether 00:e0:4c:68:00:22  txqueuelen 1000  (Ethernet)
        RX packets 6  bytes 1593 (1.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 51  bytes 6165 (6.0 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
 
> > Does it work if you unplug and plug the dangle again?
> 
> No, it didn't. Same symptom. I did try that.

Is your dangle from Samsung?
I would ask our PM to check if there is any difference between our devices.
Maybe it is not the driver issue.
 
Best Regards,
Hayes
