From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 00/13 v4] usb/net: rndis: first step toward consolidation
Date: Tue,  1 May 2012 20:22:09 +0200
Message-ID: <1335896529-13246-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:60697 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755293Ab2EASWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 14:22:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The REAL v4 patch set... forget v3 :-(

This version of the patch set squashes ex. patch 3/15 into 2/15
and creates a patch set that is bisectable at every step without
compile warnings.

Tested with the following configured in:

CONFIG_HYPERV
CONFIG_HYPERV_UTILS
CONFIG_HYPERV_NET
CONFIG_USB_USBNET
CONFIG_USB_NET_CDCETHER
CONFIG_USB_NET_RNDIS_HOST
CONFIG_USB_NET_RNDIS_WLAN
CONFIG_USB_GADGET
CONFIG_USB_ETH
CONFIG_USB_ETH_RNDIS

As mentioned in previous patch series this is to consolidate
RNDIS defines in the kernel as a first step toward consolidating
data structures and code.

Linus Walleij (13):
  usb/net: rndis: inline the cpu_to_le32() macro
  usb/net: rndis: break out <linux/rndis.h> defines
  usb/net: rndis: remove ambigous status codes
  usb/net: rndis: eliminate first set of duplicate OIDs
  usb/net: rndis: merge duplicate 802_* OIDs
  usb/net: rndis: delete surplus defines
  usb/net: rndis: group all status codes together
  usb/net: rndis: merge media type definitions
  usb/net: rndis: delete duplicate packet types
  usb/net: rndis: move and namespace PnP defines
  usb/net: rndis: merge command codes
  usb/net: rndis: fixup a few name prefixes
  usb/net: rndis: move bus message definition

 drivers/net/hyperv/hyperv_net.h   |  290 +---------------------------
 drivers/net/hyperv/rndis_filter.c |   46 +++---
 drivers/net/usb/rndis_host.c      |   52 +++---
 drivers/net/wireless/rndis_wlan.c |  295 ++++++++++++----------------
 drivers/usb/gadget/f_rndis.c      |    6 +-
 drivers/usb/gadget/ndis.h         |  164 ----------------
 drivers/usb/gadget/rndis.c        |  271 +++++++++++++-------------
 drivers/usb/gadget/rndis.h        |   48 +-----
 include/linux/rndis.h             |  390 +++++++++++++++++++++++++++++++++++++
 include/linux/usb/rndis_host.h    |   66 +------
 10 files changed, 706 insertions(+), 922 deletions(-)
 create mode 100644 include/linux/rndis.h

-- 
1.7.7.6
