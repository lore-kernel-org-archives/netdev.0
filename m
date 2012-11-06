From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v4 0/5] usbnet: avoiding access auto-suspended device
Date: Tue,  6 Nov 2012 22:53:03 +0800
Message-ID: <1352213588-8948-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:52766 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab2KFOxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 09:53:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset avoids accessing auto-suspended device in ioctl path,
which is generally triggered by some network utility(ethtool, ifconfig,
...)

Most of network devices have the problem, but as discussed in the
thread:

        http://marc.info/?t=135054860600003&r=1&w=2

the problem should be solved inside driver.

Considered that only smsc75xx and smsc95xx calls usbnet_read_cmd()
and usbnet_write_cmd() inside its resume and suspend callback, the
patcheset introduces the nopm version of the two functions which
should be called only in the resume and suspend callback. So we
can solve the problem by runtime resuming device before doing
control message things.

The patchset is against 3.7.0-rc4-next-20121105, and has been tested
OK on smsc95xx usbnet device.

Change logs:
V4:
	- kfree in failure path, only patch 3/5 changed
V3:
        - fix comment and code style reported by Sergei Shtylyov
V2:
        - rebased on the latest net-next tree, only 2/5 changed
V1:
        - rebased on 3.7.0-rc3-next-20121102, only patch 4/5 changed
        - fix one memory leak during smsc95xx_suspend, patch 3/5 added

 drivers/net/usb/smsc75xx.c |  147 +++++++++++++++++++++++++++-----------------
 drivers/net/usb/smsc95xx.c |  147 ++++++++++++++++++++++++++++----------------
 drivers/net/usb/usbnet.c   |   74 ++++++++++++++++++++--
 include/linux/usb/usbnet.h |    4 ++
 4 files changed, 258 insertions(+), 114 deletions(-)

Thanks,
--
Ming Lei
