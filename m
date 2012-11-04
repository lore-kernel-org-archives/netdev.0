From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 0/5] usbnet: avoiding access auto-suspended device
Date: Sun,  4 Nov 2012 09:29:49 +0800
Message-ID: <1351992594-12818-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55165 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab2KDBaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 21:30:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thip patchset avoids accessing auto-suspended device in ioctl path,
which is generally triggered by some network utility(ethtool, ifconfig,
...)

Most of network devices have the problem, but as discussed in the
thread:

        http://marc.info/?t=135054860600003&r=1&w=2

the problem should be solved inside driver.

Considered that only smsc75xx and smsc95xx calls usbnet_read_cmd()
and usbnet_write_cmd() inside its resume and suspend callback, the
patcheset introduce the nopm version of the two functions which
should be called only in the resume and suspend callback. So we
can solve the problem by runtime resuming device before doing
control message things.

The patchset is against 3.7.0-rc3-next-20121102, and has been tested
OK on smsc95xx usbnet device.

Change logs:
V1:
	- rebased on 3.7.0-rc3-next-20121102, only patch 4/5 changed
	- fix one memory leak during smsc95xx_suspend, patch 3/5 added

 drivers/net/usb/smsc75xx.c |  133 +++++++++++++++++++++++++---------------
 drivers/net/usb/smsc95xx.c |  146 ++++++++++++++++++++++++++++----------------
 drivers/net/usb/usbnet.c   |   72 ++++++++++++++++++++--
 include/linux/usb/usbnet.h |    4 ++
 4 files changed, 248 insertions(+), 107 deletions(-)


Thanks,
--
Ming Lei
