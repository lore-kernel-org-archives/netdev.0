From: "ASIX Allan Email [office]" <allan@asix.com.tw>
Subject: RE: [PATCH 0/4] Add a driver for the ASIX AX88172A
Date: Mon, 9 Jul 2012 10:38:52 +0800
Message-ID: <002b01cd5d7b$ff4f7390$fdee5ab0$@com.tw>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Oliver Neukum'" <oneukum@suse.de>,
	"'Eric Dumazet'" <edumazet@google.com>,
	"'Mark Lord'" <kernel@teksavvy.com>,
	"'Grant Grundler'" <grundler@chromium.org>,
	"'Ming Lei'" <tom.leiming@gmail.com>,
	"'Michael Riesch'" <michael@riesch.at>,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>,
	=?UTF-8?B?QVNJWCBGcmVkZHkgW+i+m+aBhuixkF0=?= <freddy@asix.com.tw>
To: "'Christian Riesch'" <christian.riesch@omicron.at>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:56792 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060Ab2GIDL7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 23:11:59 -0400
In-Reply-To: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

Thanks a lot for your great efforts to support AX88172A on Linux kernel mainline source.  

The following information might be useful for you to implement AX88172A Linux driver in Linux kernel mainline source. Most of AX88172A customers' applications will implement their target applications through the MII interface in MAC mode or through the Rev-MII/Rev-RMII in PHY mode, such as AX88172A (MAC mode) + external fiber PHY, AX88172A (PHY mode or Dual-PHY mode) + external MAC controller, etc. ASIX uses AX88172A EEPROM offset 17h (as Software Field setting, the AX88172A drivers will check this field value to identify the exact applications for different driver initialization procedures) to identify different customers' applications. 

For the AX88172A (PHY mode or Dual-PHY mode) + external MAC controller customers' applications that are embedded applications with AX88172A on-board design, customers should have implemented ASIX's AX88172A Linux driver source on their own embedded Linux kernel platform directly. 

For the AX88172A (MAC mode) + external fiber PHY applications that might be USB to Fiber dongle applications, users might plug the USB to Fiber dongle on any Linux kernel platforms. You can consider referring to ASIX's AX88172A Linux driver source that can be downloaded from AX88172A Driver Download web page (http://www.asix.com.tw/download.php?sub=driverdetail&PItemID=96) to support these kinds of known dongle solutions on Linux kernel mainline source if necessary. Please feel free to let us know if you need more information. Thanks a lot.
 

---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
FAX: 886-3-5799558
E-mail: allan@asix.com.tw 
http://www.asix.com.tw/ 

-----Original Message-----
From: Christian Riesch [mailto:christian.riesch@omicron.at] 
Sent: Friday, July 06, 2012 7:33 PM
To: netdev@vger.kernel.org
Cc: Oliver Neukum; Eric Dumazet; Allan Chou; Mark Lord; Grant Grundler; Ming Lei; Michael Riesch; Christian Riesch
Subject: [PATCH 0/4] Add a driver for the ASIX AX88172A

Hi,

this patch adds a driver for the ASIX AX88172A USB 2.0 to 10/100M
Fast Ethernet Controller.

Although this chip is already supported by the AX88772 code in
drivers/net/usb/asix.c, I submit a new driver since the existing
driver lacks an important feature: It only supports an
Ethernet connection using the internal PHY embedded in the AX88172A.

The driver for the AX88172A is based on drivers/net/usb/asix.c
and the work of Michael Riesch <michael@riesch.at>.

The first patch in the patchset fixes checkpatch warnings in asix.c.

The second and the third patch factor out common code which is shared
between the existing drivers and the new driver for the AX88172A.

The fourth patch finally adds support for the AX88172A.

The patchset applies on top of net-next.

I have a few questions:

1) Is it ok to factor out the common code like I did? Or should
   it go into a separate kernel module?

2) phylib/usbnet: Currently I have an empty .status function
   in my const struct driver_info ax88172a_info. I think this
   notifies me of a link change, right? I don't know
   what I should do in this function. Trigger the phy state machine
   like a phy interrupt would do, since link changes are handled
   by the phy state machine?

I have tested the patch with the ASIX AX88172A demo board (using the
internal PHY) and a custom board (AX88172A and National DP83640 PHY).

I am looking forward to your comments. Since this is my first submission
of a larger patchset to a kernel mailing list, I would like to thank you
in advance for your patience :-) The patch is in an early state and
certainly needs improvement!

Regards, Christian

Christian Riesch (4):
  asix: Fix checkpatch warnings
  asix: Rename asix.c to asix_devices.c
  asix: Factor out common code
  asix: Add a new driver for the AX88172A

 drivers/net/usb/Makefile       |    1 +
 drivers/net/usb/asix.c         | 1660 ----------------------------------------
 drivers/net/usb/asix.h         |  211 +++++
 drivers/net/usb/asix_common.c  |  525 +++++++++++++
 drivers/net/usb/asix_devices.c | 1033 +++++++++++++++++++++++++
 drivers/net/usb/ax88172a.c     |  407 ++++++++++
 6 files changed, 2177 insertions(+), 1660 deletions(-)
 delete mode 100644 drivers/net/usb/asix.c
 create mode 100644 drivers/net/usb/asix.h
 create mode 100644 drivers/net/usb/asix_common.c
 create mode 100644 drivers/net/usb/asix_devices.c
 create mode 100644 drivers/net/usb/ax88172a.c
