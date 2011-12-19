From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH series v1] IEEE 802.15.4 MAC layer basic implementation
Date: Mon, 19 Dec 2011 19:31:17 +0300
Message-ID: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49874 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab1LSPbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 10:31:47 -0500
Received: by eekc4 with SMTP id c4so5548595eek.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 07:31:46 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

the following patch series add basic support for IEEE 802.15.4 Medium Access
Control layer.

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


--
Since last post, series has been reworked to provide support for monitor device
and loopback driver only.


--
The following changes since commit d1d182e00d72300e05b18e28372fab003d8d4a58:

  wimax/i2400m: remove an unused variable (2011-12-16 15:57:03 -0500)

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

 Documentation/networking/ieee802154.txt |   57 ++++++-
 drivers/ieee802154/Kconfig              |    8 +
 drivers/ieee802154/Makefile             |    1 +
 drivers/ieee802154/fakelb.c             |  287 +++++++++++++++++++++++++++++++
 include/linux/if_arp.h                  |    1 +
 include/linux/nl802154.h                |    8 +-
 include/net/ieee802154_netdev.h         |   22 ++-
 include/net/mac802154.h                 |  153 ++++++++++++++++
 include/net/wpan-phy.h                  |    4 +-
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/ieee802154/ieee802154.h             |    2 +
 net/ieee802154/nl-phy.c                 |   10 +-
 net/ieee802154/wpan-class.c             |    1 +
 net/mac802154/Kconfig                   |   16 ++
 net/mac802154/Makefile                  |    2 +
 net/mac802154/ieee802154_dev.c          |  265 ++++++++++++++++++++++++++++
 net/mac802154/mac802154.h               |  102 +++++++++++
 net/mac802154/mac_cmd.c                 |   43 +++++
 net/mac802154/mib.c                     |   96 ++++++++++
 net/mac802154/monitor.c                 |  115 ++++++++++++
 net/mac802154/rx.c                      |  107 ++++++++++++
 net/mac802154/tx.c                      |  113 ++++++++++++
 23 files changed, 1402 insertions(+), 13 deletions(-)
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

With best regards,
Alexander Smirnov
