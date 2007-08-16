From: Oliver Neukum <oliver@neukum.org>
Subject: zd1211rw regression, device does not enumerate
Date: Thu, 16 Aug 2007 14:25:11 +0200
Message-ID: <200708161425.12217.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	Daniel Drake <dsd@gentoo.org>,
	John W.Linville <linville@tuxdriver.com>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

after bisection it boils down to this patch:

oliver@oenone:/home/olli2/Trees/linux-2.6> git bisect bad
74553aedd46b3a2cae986f909cf2a3f99369decc is first bad commit
commit 74553aedd46b3a2cae986f909cf2a3f99369decc
Author: Daniel Drake <dsd@gentoo.org>
Date:   Sun Jul 1 18:22:32 2007 +0100

    [PATCH] zd1211rw: Defer firmware load until first ifup

that plugging in my device I get an error:
Aug 16 13:17:11 oenone kernel: zd1211rw 3-4.3:1.0: zd1211b chip 0ace:1215 v4810 high 00-02-72 AL2230_RF pa0 g--NS
Aug 16 13:17:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: unlink qh1-0001/ffff810037c04960 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: ehci_hcd 0000:00:02.2: reused qh ffff810037c04960 schedule
Aug 16 13:17:11 oenone kernel: usb 3-4.3: link qh1-0001/ffff810037c04960 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff810037c04a00 start 0 [2/0 us]
Aug 16 13:17:12 oenone ifup: Cannot enable interface eth2.
Aug 16 13:17:12 oenone kernel: zd1211rw 3-4.3:1.0: error ioread32(CR_REG1): -110
Aug 16 13:17:12 oenone kernel: usb 3-4.3: unlink qh1-0001/ffff810037c04960 start 0 [2/0 us]
Aug 16 13:17:12 oenone ifup-route: interface eth2 is not up

Bus 003 Device 006: ID 0ace:1215 ZyDAS
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol       255 Vendor Specific Protocol
  bMaxPacketSize0        64
  idVendor           0x0ace ZyDAS
  idProduct          0x1215
  bcdDevice           48.10
  iManufacturer          16 ZyDAS
  iProduct               32 USB2.0 WLAN
  iSerial                 0
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           46
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0
    bmAttributes         0x80
      (Bus Powered)
    MaxPower              500mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           4
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      0
      bInterfaceProtocol      0
      iInterface              0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x01  EP 1 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
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
        bEndpointAddress     0x83  EP 3 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               1
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x04  EP 4 OUT
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               1
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol       255 Vendor Specific Protocol
  bMaxPacketSize0        64
  bNumConfigurations      1
Device Status:     0x0000
  (Bus Powered)

	Regards
		Oliver

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
