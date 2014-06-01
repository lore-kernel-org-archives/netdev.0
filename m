From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH 0/2] rt2800usb: Fix support for USB 057c:8501
Date: Sun, 01 Jun 2014 19:52:42 +0200
Message-ID: <20140601174736.7980.18330.stgit@charlie.fem.tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Ivo van Doorn <IvDoorn@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:44888 "EHLO
	mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaFASEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 14:04:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usb wifi device AVM Fritz Stick N v2b (USB 057c:8501) is listed as supported by rt2800usb, but loading the driver fails for me (kernel 3.15-rc7 and older).

 ieee80211 phy0: rt2x00_set_rt: Info - RT chipset 5592, rev 0222 detected
 ieee80211 phy0: rt2x00usb_vendor_request: Error - Vendor Request 0x09 failed for offset 0x0000 with error -32
 ieee80211 phy0: rt2x00lib_probe_dev: Error - Failed to allocate device
 rt2800usb: probe of 1-1.3:1.0 failed with error -32
 usbcore: registered new interface driver rt2800usb

>From searching the web, it looks like other users using the same device are hit by this error too, and some users of similar devices using the same driver experience similar errors.

I've tested these patches using a USB 057c:8501 wifi device in client mode (scanning + connect to WPA protected BSS + network access). With the patches applied, the device works fine. Without, it fails.
I've also tested that USB 148f:5370 (which is another usb wifi device using the same driver), which worked also without these patches applied, still works after applying these patches.

Regards,
 M. Braun
---

Michael Braun (2):
      rt2800usb:fix efuse detection
      rt2800usb:fix hang during firmware load


 drivers/net/wireless/rt2x00/rt2800usb.c |   30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)
