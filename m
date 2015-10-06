From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 105441] New: r8152: Autonegotiation does not detect link
Date: Tue, 6 Oct 2015 10:31:17 +0100
Message-ID: <20151006103117.6bff3d75@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34794 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJFJb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 05:31:27 -0400
Received: by wicfx3 with SMTP id fx3so157078137wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 02:31:26 -0700 (PDT)
Received: from uryu.home.lan ([89.101.192.72])
        by smtp.gmail.com with ESMTPSA id gh9sm31460017wjb.27.2015.10.06.02.31.25
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 02:31:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 4 Oct 2015 10:52:56 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 105441] New: r8152: Autonegotiation does not detect link


https://bugzilla.kernel.org/show_bug.cgi?id=105441

            Bug ID: 105441
           Summary: r8152: Autonegotiation does not detect link
           Product: Networking
           Version: 2.5
    Kernel Version: 4.2.0-1-686-pae #1 SMP Debian 4.2.1-2 (2015-09-27)
                    i686 GNU/Linux
          Hardware: i386
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: jkufner@gmail.com
        Regression: No

Hardware: Thinkpad Yoga 12 and 1Gbps USB ethernet adapter from Lenovo -- lsusb:
  idVendor           0x17ef Lenovo
  idProduct          0x7205
  bcdDevice           30.00
  iManufacturer           1 Lenovo
  iProduct                2 ThinkpadUSBLAN

Link is not detected after plugging ethernet adapter into USB port -- dmesg:

[ 1458.764163] usb 2-2: new SuperSpeed USB device number 6 using xhci_hcd
[ 1458.780614] usb 2-2: New USB device found, idVendor=17ef, idProduct=7205
[ 1458.780620] usb 2-2: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[ 1458.780623] usb 2-2: Product: ThinkpadUSBLAN
[ 1458.780625] usb 2-2: Manufacturer: Lenovo
[ 1458.780628] usb 2-2: SerialNumber: 3C18A002BEE5
[ 1458.896539] usb 2-2: reset SuperSpeed USB device number 6 using xhci_hcd
[ 1458.939516] r8152 2-2:1.0 eth0: v1.08.1 (2015/07/28)
[ 1459.035214] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[ 1459.495124] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 1459.541189] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready

But when I do:

  ethtool -s eth0 autoneg off

It starts to work correctly -- dmesg:

[ 1528.221326] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

It worked with kernels older than 4.0 (I'm not sure about 4.0). It was broken
with 4.1. I'm using kernel from 32bit Debian.

-- 
You are receiving this mail because:
You are the assignee for the bug.
