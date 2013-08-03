From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 0/4] USB & USBNET: loose SG check and support usbnet DMA SG
Date: Sat,  3 Aug 2013 10:46:33 +0800
Message-ID: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:36917 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088Ab3HCCrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 22:47:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset allows drivers to pass sg buffers which size can't be divided
by max packet size of endpoint if the host controllers(such ax xHCI) support
this kind of sg buffers.

Previously we added check[1] on the situation and don't allow these sg buffers
passed to USB HCD, looks the check is too strict to make use of new feature of
new hardware(xHCI) for some applications(such as network stack) which can't
provide this kind of sg buffers to usbnet driver, so the patch looses the check
in case that the host controller supports it.

Patch 3/4 implements DMA SG on usbnet driver, and patch 4/4 uses it on ax88179_178a
USB3 NIC for supporting TSO, so both CPU utilization and tx throughput can be
improved with TSO and DMA SG in case of the USB NIC is attached to xHCI controller.

This patchset is against Eric Dumazet's patch(ax88179_178a: avoid copy of tx
tcp packets), so maybe it is better to merge via net-next tree.

[1], http://git.kernel.org/cgit/linux/kernel/git/gregkh/usb.git/commit/?h=usb-next&id=10e232c597ac757e7f8600649f7e872e86de190f

V1:
	- introduce and apply usb_device_no_sg_limit() helper as suggested by Greg
	- simplify patch 4/4 against Eric Dumazet's patch(ax88179_178a: avoid copy of tx tcp packets)
	- don't pass usbnet header as sg buffer

 drivers/net/usb/ax88179_178a.c |   12 ++++++++++++
 drivers/net/usb/usbnet.c       |   38 ++++++++++++++++++++++++++++++++++++--
 drivers/usb/core/urb.c         |    3 ++-
 drivers/usb/host/xhci.c        |    4 ++++
 include/linux/usb.h            |   11 ++++++++++-
 include/linux/usb/usbnet.h     |    1 +
 6 files changed, 65 insertions(+), 4 deletions(-)


Thanks,
--
Ming Lei
