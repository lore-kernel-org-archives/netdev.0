From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: (unknown)
Date: Mon, 26 Dec 2011 18:55:26 +0300
Message-ID: <CAJmB2rB+f+SpeCWWfi8Ao-gDjs1pugSiEjYWSZ7JsrmQ82WQuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-zigbee-devel <linux-zigbee-devel@lists.sourceforge.net>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:42912 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750955Ab1LZPz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 10:55:28 -0500
Received: by lahd3 with SMTP id d3so1843512lah.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 07:55:27 -0800 (PST)
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David, colleagues,

sorry, forgot to add netdev list.

This is the second version of patch series which adds basic support for
IEEE 802.15.4 Medium Access Control layer.

The IEEE 802.15.4 Working Group focuses on the standardization of the
bottom two layers of ISO/OSI protocol stack: Physical (PHY) and MAC.
The MAC layer provides access control to a shared channel and reliable
data delivery.

This series provide only basic features:
 - interface for drivers registration
 - RX/TX datapaths
 - reduced mlme operations
 - monitor device type support (used by network sniffers, e.g. Wireshark)
 - IEEE 802.15.4 loopback driver
 - documentation update

With best regards,
Alexander

--

Changes since last post:
 * lots and lots of coding style and poor formating issues
 * additional comments
 * using proper byte order (little endian)
 * locking in loopback driver
 * mac802154: allocation of ieee802154 device: using of NETDEV_ALIGN,
  reworked like for ieee80211 stack (net/mac80211/main.c)
  The reason why I use alignment of data in ieee802154 layer is because of
  there are two levels of private data: mac layer's and driver's.

--

The following changes since commit eb93992207dadb946a3b5cf4544957dc924a6f58:

 module_param: make bool parameters really bool (net & drivers/net)
(2011-12-19 22:27:29 -0500)

are available in the git repository at:
 git://linux-zigbee.git.sourceforge.net/gitroot/linux-zigbee/kernel to_upstream

Alexander Smirnov (14):
     mac802154: basic ieee802.15.4 device structures
     mac802154: allocation of ieee802154 device
     mac802154: RX data path
     mac802154: TX data path
     mac802154: define reduced mlme operations
     mac802154: slave interfaces definition
     mac802154: reduced mlme operations
     mac802154: basic mib support
     ieee802154: remove ieee802154 policy from globals
     ieee802154: interface type to be added
     mac802154: slaves manipulation routine
     mac802154: monitor device support
     drivers/ieee802154: IEEE 802.15.4 loopback driver
     Documentation/networking/ieee802154: update MAC chapter

 Documentation/networking/ieee802154.txt |   75 ++++++--
 drivers/ieee802154/Kconfig              |    8 +
 drivers/ieee802154/Makefile             |    1 +
 drivers/ieee802154/fakelb.c             |  293 +++++++++++++++++++++++++++++++
 include/linux/if_arp.h                  |    1 +
 include/linux/nl802154.h                |   19 ++-
 include/net/ieee802154_netdev.h         |   26 +++-
 include/net/mac802154.h                 |  157 +++++++++++++++++
 include/net/wpan-phy.h                  |    5 +-
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/ieee802154/ieee802154.h             |    2 +
 net/ieee802154/nl-phy.c                 |    9 +-
 net/ieee802154/wpan-class.c             |    1 +
 net/mac802154/Kconfig                   |   16 ++
 net/mac802154/Makefile                  |    2 +
 net/mac802154/ieee802154_dev.c          |  269 ++++++++++++++++++++++++++++
 net/mac802154/mac802154.h               |  107 +++++++++++
 net/mac802154/mac_cmd.c                 |   43 +++++
 net/mac802154/mib.c                     |   97 ++++++++++
 net/mac802154/monitor.c                 |  115 ++++++++++++
 net/mac802154/rx.c                      |  110 ++++++++++++
 net/mac802154/tx.c                      |  113 ++++++++++++
 23 files changed, 1447 insertions(+), 24 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 include/net/mac802154.h
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/ieee802154_dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/mib.c
 create mode 100644 net/mac802154/monitor.c
 create mode 100644 net/mac802154/rx.c
 create mode 100644 net/mac802154/tx.c
