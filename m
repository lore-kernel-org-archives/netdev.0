From: Ondrej Zary <linux@rainbow-software.org>
Subject: cxacru: USB ethernet port of CX82310-based ADSL routers?
Date: Tue, 31 Aug 2010 23:13:36 +0200
Message-ID: <201008312313.39171.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: accessrunner-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: cxacru@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:57379 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754045Ab0HaVNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 17:13:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I have an ADSL router based on Conexant CX82310 chip. This chip provides both
ethernet and USB interfaces. The ethernet interface is often internally
connected to a 5-port switch (in my case too). The USB interface works as an
ethernet card in Windows (using proprietary driver). In Linux, the cxacru
driver binds to the device but does not work (no wonder - it's doing firmware
things in an attempt to bring an ADSL modem up).

I captured a log from Windows (device connect, DHCP and disconnect):
http://www.rainbow-software.org/linux_files/cx82310/cx-run-dhcp.log

The commands seem to match the enums in cxacru
driver (and go to endpoint 1):
0x84, 0x85, 0x90, 0x91, 0x92, 0x99 (unknown)
Data goes to/from endpoint 2 as ethernet frames (with something at the
beginning).

I wonder how to implement support for this device in cxacru driver. Or would
be a separate driver better?


lsusb output:

Bus 001 Device 003: ID 0572:cb01 Conexant Systems (Rockwell), Inc. GeekADSL Promax Q31 ADSL Modem
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass         0 
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  idVendor           0x0572 Conexant Systems (Rockwell), Inc.
  idProduct          0xcb01 GeekADSL Promax Q31 ADSL Modem
  bcdDevice            1.00
  iManufacturer           1 -
  iProduct                2 USB NET CARD
  iSerial                 3 00000060
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           67
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xc0
      Self Powered
    MaxPower               80mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           7
      bInterfaceClass         0 (Defined at Interface level)
      bInterfaceSubClass      0 
      bInterfaceProtocol      0 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               4
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x01  EP 1 OUT
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               4
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x82  EP 2 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               1
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               1
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x83  EP 3 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               1
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               1
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x84  EP 4 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval               4
Device Status:     0x0001
  Self Powered


-- 
Ondrej Zary
