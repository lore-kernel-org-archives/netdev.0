From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy init
 for AX88772 USB ethernet".
Date: Fri, 06 Jan 2012 13:10:51 +0200
Message-ID: <20120106131051.92814bd4b7x0nmqs@www.81.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_48v6xlmzq86c"
Content-Transfer-Encoding: 7bit
Cc: Freddy Xin <freddy@asix.com.tw>,
	Grant Grundler <grundler@chromium.org>,
	Olof Johansson <olofj@chromium.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Hollis <dhollis@davehollis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-01.sanoma.fi ([158.127.18.161]:52669 "EHLO
	sd-mail-sa-01.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758477Ab2AFLSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 06:18:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_48v6xlmzq86c
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Hello,

I have asix adapter plugged to mini-server and have to change MAC  
address before DHCP because of ISP. This worked fine, until v3.2. Now  
I have to set interface in promisc mode to have custom MAC working.

I bisected problem to '[4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378] NET:  
fix phy init for AX88772 USB ethernet':

# bad: [5f0a6e2d503896062f641639dacfe5055c2f593b] Linux 3.2-rc7
# good: [c3b92c8787367a8bb53d57d9789b558f1295cc96] Linux 3.1
git bisect start 'v3.2-rc7' 'v3.1' 'drivers/net/usb/asix.c'
# bad: [79de9efdb93d8e693dccd0eb7d80cd6092f5875b] NET: asix: fix  
ethtool -e for AX88178 USB dongle
git bisect bad 79de9efdb93d8e693dccd0eb7d80cd6092f5875b
# bad: [4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378] NET: fix phy init  
for AX88772 USB ethernet
git bisect bad 4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378
# good: [afc4b13df143122f99a0eb10bfefb216c2806de0] net: remove use of  
ndo_set_multicast_list in drivers
git bisect good afc4b13df143122f99a0eb10bfefb216c2806de0

-Jussi


--=_48v6xlmzq86c
Content-Type: text/plain;
 charset=UTF-8;
 name="lsusb.txt"
Content-Disposition: attachment;
 filename="lsusb.txt"
Content-Transfer-Encoding: 7bit


Bus 001 Device 002: ID 0b95:7720 ASIX Electronics Corp. AX88772
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  idVendor           0x0b95 ASIX Electronics Corp.
  idProduct          0x7720 AX88772
  bcdDevice            0.01
  iManufacturer           1 ASIX Elec. Corp.
  iProduct                2 AX88772 
  iSerial                 3 000001
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           39
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          4 0
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower              250mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass    255 Vendor Specific Subclass
      bInterfaceProtocol      0 
      iInterface              7 0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval              11
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x82  EP 2 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol         0 
  bMaxPacketSize0         8
  bNumConfigurations      1
Device Status:     0x0001
  Self Powered

--=_48v6xlmzq86c--
