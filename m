From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 0/13 v3] basic IEEE 802.15.4 MAC support
Date: Tue, 28 Feb 2012 18:00:19 +0300
Message-ID: <1330441232-17650-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	dbaryshkov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35589 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab2B1OFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 09:05:43 -0500
Received: by eaah12 with SMTP id h12so2585014eaa.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 06:05:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi David,

This is the 3-rd version of patch series for IEEE 802.15.4 Medium Access
Control layer support. Originally the code was provided by linux-zigbee
sourceforge project and is based on 80211 implementation.


The previous post was in December, 19th.

Changes since last post (v1):
 * lots and lots of coding style and poor formating issues
 * additional comments in code
 * using proper byte order (little endian)
 * locking during state changes in loopback driver (patch 0012)
 * replace integer bit-field by bool
 * exclude usage of enums
 * removed excessive assertions
 * drop one patch (ieee802154: remove ieee802154 policy from globals). The
   idea was to remove extra coupling in code, but it not so easy as I assumed
   and has nothing common with MAC routine

But I still have some hesitations about following 2 points:
 * [PATCH 02/13] mac802154: allocation of ieee802154 device:
   you asked me to make wpan_phy_alloc() take care of alignment, and just pass
   the minimum amount of information necessary for it to calculate the right
   size.

   The problem is that wpan private area is used by both: mac and driver, so
   to align both of them we should pass an extra argument to wpan_phy_alloc,
   not sure if it'd be nice.

   This code is completely based on net/mac80211/main.c file and also I've
   added an extra comment in code.

 * [PATCH 09/13] ieee802154: interface type to be added:
   I've defined device-types by using enum. This approach makes life simple in
   checking device type scope (i.e. check that value obtained is correct device
   type).

So, could you please review the following patches?

With best regards,
Alexander Smirnov

--
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
The following changes since commit ff4783ce78c08d2990126ce1874250ae8e72bbd2:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-02-26 21:55:51 -0500)

are available in the git repository at:

  git://linux-zigbee.git.sourceforge.net/gitroot/linux-zigbee/kernel

Alexander Smirnov (13):
      mac802154: basic ieee802.15.4 device structures
      mac802154: allocation of ieee802154 device
      mac802154: RX data path
      mac802154: TX data path
      mac802154: define reduced mlme operations
      mac802154: slave interfaces definition
      mac802154: declare reduced mlme operations
      mac802154: basic mib support
      ieee802154: interface type to be added
      mac802154: slaves manipulation routine
      mac802154: monitor device support
      drivers/ieee802154: IEEE 802.15.4 loopback driver
      Documentation/networking/ieee802154: update MAC chapter

 Documentation/networking/ieee802154.txt |   75 ++++++--
 drivers/ieee802154/Kconfig              |    8 +
 drivers/ieee802154/Makefile             |    1 +
 drivers/ieee802154/fakelb.c             |  294 +++++++++++++++++++++++++++++++
 include/linux/if_arp.h                  |    1 +
 include/linux/nl802154.h                |   22 +++
 include/net/ieee802154_netdev.h         |   26 +++-
 include/net/mac802154.h                 |  141 +++++++++++++++
 include/net/wpan-phy.h                  |    5 +-
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/ieee802154/nl-phy.c                 |    9 +-
 net/mac802154/Kconfig                   |   16 ++
 net/mac802154/Makefile                  |    2 +
 net/mac802154/ieee802154_dev.c          |  291 ++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h               |  105 +++++++++++
 net/mac802154/mac_cmd.c                 |   44 +++++
 net/mac802154/mib.c                     |   97 ++++++++++
 net/mac802154/monitor.c                 |  116 ++++++++++++
 net/mac802154/rx.c                      |  110 ++++++++++++
 net/mac802154/tx.c                      |  113 ++++++++++++
 21 files changed, 1456 insertions(+), 22 deletions(-)
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
