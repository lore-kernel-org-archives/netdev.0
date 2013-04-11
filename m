From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 00/11] usbnet: usbnet: handle link change
Date: Thu, 11 Apr 2013 22:40:29 +0800
Message-ID: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:44617 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932712Ab3DKOky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:40:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set introduces usbnet_link_change() API and applies
it on all usbnet drivers, then handle the link change centrally
to stop bulk transfer when link becomes off and restart bulk
transfer when link becomes on.

With the change, ~10% performance boost on bulk transfer
of another device on the same bus can be obtained when link
is off. Also, stopping bulk transfer when link becomes off
may disable asynchonous schedule of host controller, power
might be saved probabally.

 drivers/net/usb/asix_devices.c |    6 +-----
 drivers/net/usb/ax88179_178a.c |   12 ++++-------
 drivers/net/usb/cdc_ether.c    |    5 +----
 drivers/net/usb/cdc_ncm.c      |    9 +++-----
 drivers/net/usb/dm9601.c       |    7 +------
 drivers/net/usb/mcs7830.c      |    6 +-----
 drivers/net/usb/sierra_net.c   |    3 +--
 drivers/net/usb/usbnet.c       |   45 +++++++++++++++++++++++++++++++++++++++-
 include/linux/usb/usbnet.h     |    2 ++
 9 files changed, 58 insertions(+), 37 deletions(-)


Thanks,
--
Ming Lei
