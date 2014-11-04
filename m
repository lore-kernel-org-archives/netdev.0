From: Riku Voipio <riku.voipio@iki.fi>
Subject: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net on
 arndale platform
Date: Tue, 4 Nov 2014 09:22:36 +0200
Message-ID: <20141104072236.GA559@afflict.kos.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org
To: davem@davemloft.net, Michel Stam <m.stam@fugro.nl>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

With 3.18-rc3, asix on arndale (samsung exynos 5250 based board), fails
to work. Interface is initialized but network traffic seem not to pass
through. With kernel IP config the result looks like:

[    3.323275] usb 3-3.2.4: new high-speed USB device number 4 using exynos-ehci
[    3.419151] usb 3-3.2.4: New USB device found, idVendor=0b95, idProduct=772a
[    3.424735] usb 3-3.2.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.432196] usb 3-3.2.4: Product: AX88772 
[    3.436279] usb 3-3.2.4: Manufacturer: ASIX Elec. Corp.
[    3.441486] usb 3-3.2.4: SerialNumber: 000001
[    3.447530] asix 3-3.2.4:1.0 (unnamed net_device) (uninitialized): invalid hw address, using random
[    3.764352] asix 3-3.2.4:1.0 eth0: register 'asix' at usb-12110000.usb-3.2.4, ASIX AX88772 USB 2.0 Ethernet, de:a2:66:bf:ca:4f
[    4.488773] asix 3-3.2.4:1.0 eth0: link down
[    5.690025] asix 3-3.2.4:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[    5.712947] Sending DHCP requests ...... timed out!
[   83.165303] IP-Config: Retrying forever (NFS root)...
[   83.170397] asix 3-3.2.4:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   83.192944] Sending DHCP requests .....

Similar results also with dhclient. Git bisect identified the breaking commit as:

commit 3cc81d85ee01e5a0b7ea2f4190e2ed1165f53c31
Author: Michel Stam <m.stam@fugro.nl>
Date:   Thu Oct 2 10:22:02 2014 +0200

    asix: Don't reset PHY on if_up for ASIX 88772

Taking 3.18-rc3 and that commit reverted, network works again:

[    3.303500] usb 3-3.2.4: new high-speed USB device number 4 using exynos-ehci
[    3.399375] usb 3-3.2.4: New USB device found, idVendor=0b95, idProduct=772a
[    3.404963] usb 3-3.2.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.412424] usb 3-3.2.4: Product: AX88772 
[    3.416508] usb 3-3.2.4: Manufacturer: ASIX Elec. Corp.
[    3.421715] usb 3-3.2.4: SerialNumber: 000001
[    3.427755] asix 3-3.2.4:1.0 (unnamed net_device) (uninitialized): invalid hw address, using random
[    3.744837] asix 3-3.2.4:1.0 eth0: register 'asix' at usb-12110000.usb-3.2.4, ASIX AX88772 USB 2.0 Ethernet, 12:59:f1:a8:43:90
[    7.098998] asix 3-3.2.4:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[    7.118258] Sending DHCP requests ., OK
[    9.753259] IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.111

There might something wrong on the samsung platform code (I understand the
USB on arndale is "funny"), but this is still an regression from 3.17.

Riku
