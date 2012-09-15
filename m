From: Ming Lei <ming.lei@canonical.com>
Subject: [RFC PATCH 0/3] usbnet: support runtime PM triggered by link change
Date: Sun, 16 Sep 2012 01:48:16 +0800
Message-ID: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, Fink Dmitry <finik@ti.com>,
	Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52585 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab2IORsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 13:48:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently only very few usbnet devices support the traffic based
runtime PM, eg. wake up devices if there are packets to be transmitted.

For the below situation, it should make sense to runtime suspend usbnet
device to save power:
	
	- after network link becomes down

This patch implements the runtime PM triggered by network link change
event, and it works basically on asix usbnet device after a simple
runtime PM test.

 drivers/net/usb/asix_devices.c |    6 +-
 drivers/net/usb/cdc_ether.c    |    5 +-
 drivers/net/usb/cdc_ncm.c      |    9 +-
 drivers/net/usb/dm9601.c       |    7 +-
 drivers/net/usb/mcs7830.c      |    6 +-
 drivers/net/usb/sierra_net.c   |    6 +-
 drivers/net/usb/usbnet.c       |  224 +++++++++++++++++++++++++++++++++++++++-
 include/linux/usb/usbnet.h     |   21 +++-
 8 files changed, 250 insertions(+), 34 deletions(-)


Thanks
--
Ming Lei
