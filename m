From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 00/12] usbnet: usb_control_msg cleanup
Date: Tue,  2 Oct 2012 14:51:11 +0800
Message-ID: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53713 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961Ab2JBGvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 02:51:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set introduces 3 helpers for handling usb read, write
and write_async command, and replaces the low level's implemention
with the generic ones.

Firstly, it is a cleanup and about 300 lines code can be saved.

Secondly, the patch fixes DMA on the buffer which is embedded inside
one dynamic allocated buffer, and such usages can be found
in cdc-ncm, sierra_net, mcs7830 and asix drivers.

Finally, almost all low level drivers don't consider runtime
PM situation when reading/writing control command to device via
usb_control_message. For example, 'ethtool' may touch a suspended
device and kind of below message will be dumped:

	[tom@tom-pandaboard ~]$ ethtool eth0
	Settings for eth[  117.084411] smsc95xx 1-1.1:1.0 eth0: Failed to read register index 0x00000114
	0:
	[  117.093139] smsc95xx 1-1.1:1.0 eth0: Error reading MII_ACCESS
	[  117.099395] smsc95xx 1-1.1:1.0 eth0: MII is busy in smsc95xx_mdio_read

This patch fixes the problem above by holding runtime PM referece
count before calling usb_control_msg.

 drivers/net/usb/asix_common.c |  117 ++++-------------------------------
 drivers/net/usb/cdc_ncm.c     |   73 +++++++---------------
 drivers/net/usb/dm9601.c      |  107 +++++---------------------------
 drivers/net/usb/int51x1.c     |   52 +---------------
 drivers/net/usb/mcs7830.c     |   85 ++-----------------------
 drivers/net/usb/net1080.c     |  110 +++++++++------------------------
 drivers/net/usb/plusb.c       |   11 ++--
 drivers/net/usb/sierra_net.c  |   45 +++++---------
 drivers/net/usb/smsc75xx.c    |   39 +++++-------
 drivers/net/usb/smsc95xx.c    |  115 ++++++++--------------------------
 drivers/net/usb/usbnet.c      |  137 +++++++++++++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h    |    6 ++
 12 files changed, 295 insertions(+), 602 deletions(-)


Thanks,
--
Ming Lei
