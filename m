From: Grant Grundler <grundler@google.com>
Subject: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Mon, 10 Feb 2014 17:38:39 -0800
Message-ID: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: inky.yoo@samsung.com, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:43016 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbaBKBik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 20:38:40 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so8483364oag.40
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 17:38:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hayes,
"r8152: ecm and vendor modes coexist" patch prevents RTL8153 device
from establishing a link in the backport I've worked on for
chromeos-3.8 kernel. IIRC, r815x driver claims this device. Without
this patch, r8152 is able to establish a link with RTL8153 device.

This was the last patch in the series of 40 patches that I
cherry-picked and r8152 driver seems to "basically" work WITHOUT this
last patch.  I've not tested much yet...but DHCP worked and I'm able
to run netperf tests. I've not investigated why this patch fails and
probably won't.

If you have opportunity, can you confirm RTL8153 devices work for you
with any recent upstream kernel?

I'm testing with a Realtek branded device that lsusb says is:
   Bus 002 Device 002: ID 0bda:8153 Realtek Semiconductor Corp.

cheers
grant

git log drivers/net/usb/r8152.c
...
commit c7de7dec2ff2528ec630c55e68c25bd9d972b677
Author: hayeswang <hayeswang@realtek.com>
Date:   Wed Jan 15 10:42:16 2014 +0800

    r8152: ecm and vendor modes coexist

    Remove the limitation that the ecm and r8152 drivers couldn't coexist.
     - Remove the devices from the blacklist of relative drivers.
     - Remove usb_driver_set_configuration() from r8152 driver.
     - Modify the id_table of the r8152 driver for the vendor mode only.

    Signed-off-by: Hayes Wang <hayeswang@realtek.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
