From: Olivier Blin <olivier.blin@softathome.com>
Subject: [PATCH net 0/3] cdc-ether: handle promiscuous mode
Date: Fri, 24 Oct 2014 19:42:59 +0200
Message-ID: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: oneukum@suse.de, hayeswang@realtek.com, bjorn@mork.no,
	davem@davemloft.net, Olivier Blin <olivier.blin@softathome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 92-137-167-83.reverse.alphalink.fr ([83.167.137.92]:39355 "EHLO
	mtantr1.softathome.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040AbaJXRwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 13:52:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Since kernel 3.16, my Lenovo USB network adapters (RTL8153) using
cdc-ether are not working anymore in a bridge.

This is due to commit c472ab68ad67db23c9907a27649b7dc0899b61f9, which
resets the packet filter when the device is bound.

The default packet filter set by cdc-ether does not include
promiscuous, while the adapter seemed to have promiscuous enabled by
default.

This patch series allows to support promiscuous mode for cdc-ether, by
hooking into set_rx_mode.

Incidentally, maybe this device should be handled by the r8152 driver,
but this patch series is still nice for other adapters.

Thanks

Olivier Blin (3):
  usbnet: add a callback for set_rx_mode
  cdc-ether: extract usbnet_cdc_update_filter function
  cdc-ether: handle promiscuous mode with a set_rx_mode callback

 drivers/net/usb/cdc_ether.c | 47 +++++++++++++++++++++++++++++++--------------
 drivers/net/usb/usbnet.c    | 20 +++++++++++++++++++
 include/linux/usb/usbnet.h  |  4 ++++
 3 files changed, 57 insertions(+), 14 deletions(-)

-- 
2.1.2

-- This message and any attachments herein are confidential, intended solely for the addressees and are SoftAtHome.s ownership. Any unauthorized use or dissemination is prohibited. If you are not the intended addressee of this message, please cancel it immediately and inform the sender.
-- This message and any attachments herein are confidential, intended solely for the addressees and are SoftAtHome.s ownership. Any unauthorized use or dissemination is prohibited. If you are not the intended addressee of this message, please cancel it immediately and inform the sender.
