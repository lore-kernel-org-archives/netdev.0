From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 13 Jan 2010 18:34:14 -0800 (PST)
Message-ID: <20100113.183414.78087756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38699
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751560Ab0ANCeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 21:34:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wireless bug fixes via John Linville (killing the master device
screwed up multiqueue and also allowed TX queue to backlog
indefinitely if stopped, oops).

net/ip.h build fix from Octavian Purdila.

Two SFC bug fixes from Ben Hutchings (schedule() vs.
schedule_timeout_interruptible(), MDIO self-test check
fix).

E11000E/IXGBE bug fixes via the Intel folks (MDIO slow mode done
on wrong chips, half duplex backoff bug, elide netpoll execution
when the chip is down and resources have been freed).

TG3 bug fixes from Matt Carlson, including a nasty fix for a regression
that would cause RX to completely wedge due to mishandling of the
producer ring.

And, of course, the ipv6 skb_dst()==NULL fix.

Please pull, thanks a lot!

The following changes since commit 7284ce6c9f6153d1777df5f310c959724d1bd446:
  Linus Torvalds (1):
        Linux 2.6.33-rc4

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (1):
      iwlwifi: disable tx on beacon update notification

Alexander Duyck (1):
      ixgbe: Do not attempt to perform interrupts in netpoll when down

Ben Hutchings (2):
      sfc: Fix polling for slow MCDI operations
      sfc: Fix conditions for MDIO self-test

Benoit Papillault (1):
      zd1211rw: Fix multicast filtering.

Bruce Allan (2):
      e1000e: MDIO slow mode should always be done for 82577
      e1000e: workaround link issues on busy hub in half duplex on 82577/82578

Dan Carpenter (2):
      iwl: off by one bug
      iwlwifi: silence buffer overflow warning

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      ipv6: skb_dst() can be NULL in ipv6_hop_jumbo().

Dominik Geyer (1):
      ath9k: Fix Kconfig depends for ATH9K_DEBUGFS

Felix Fietkau (2):
      mac80211: add missing sanity checks for action frames
      mac80211: fix queue selection for data frames on monitor interfaces

Gertjan van Wingerde (2):
      rt2x00: Fix LED configuration setting for rt2800.
      rt2x00: Properly request tx headroom for alignment operations.

Johannes Berg (3):
      mac80211: fix skb buffering issue
      mac80211: fix endian error
      cfg80211: fix refcount imbalance when wext is disabled

John W. Linville (2):
      mac80211: fix-up build breakage in 2.6.33
      Revert "mac80211: replace netif_tx_{start,stop,wake}_all_queues"

Lennert Buytenhek (2):
      mwl8k: fix configure_filter() memory leak on error
      mac80211: fix queue selection for packets injected via monitor interface

Luis R. Rodriguez (2):
      ath5k: Fix eeprom checksum check for custom sized eeproms
      cfg80211: fix syntax error on user regulatory hints

Matt Carlson (5):
      tg3: Fix std prod ring nicaddr for 5787 and 57765
      tg3: Fix std rx prod ring handling
      tg3: Add reliable serdes detection for 5717 A0
      tg3: Disable 5717 serdes and B0 support
      tg3: Update copyright and driver version

Ming Lei (1):
      ath9k: fix ito64

Octavian Purdila (1):
      net: fix build erros with CONFIG_BUG=n, CONFIG_GENERIC_BUG=n

Pavel Roskin (1):
      rt2x00: use correct headroom for transmission

Shannon Nelson (1):
      ixgbe: update copyright dates

Zhu Yi (1):
      iwlwifi: fix iwl_queue_used bug when read_ptr == write_ptr

 drivers/net/e1000e/e1000.h                |    1 -
 drivers/net/e1000e/ich8lan.c              |   76 +++++++++++++++++++++--
 drivers/net/e1000e/phy.c                  |   85 -------------------------
 drivers/net/ixgbe/Makefile                |    2 +-
 drivers/net/ixgbe/ixgbe.h                 |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c           |    2 +-
 drivers/net/ixgbe/ixgbe_82599.c           |    2 +-
 drivers/net/ixgbe/ixgbe_common.c          |    2 +-
 drivers/net/ixgbe/ixgbe_common.h          |    2 +-
 drivers/net/ixgbe/ixgbe_dcb.c             |    2 +-
 drivers/net/ixgbe/ixgbe_dcb.h             |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.c       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.h       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.h       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c          |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c         |    2 +-
 drivers/net/ixgbe/ixgbe_fcoe.c            |    2 +-
 drivers/net/ixgbe/ixgbe_fcoe.h            |    2 +-
 drivers/net/ixgbe/ixgbe_main.c            |    8 ++-
 drivers/net/ixgbe/ixgbe_phy.c             |    2 +-
 drivers/net/ixgbe/ixgbe_phy.h             |    2 +-
 drivers/net/ixgbe/ixgbe_type.h            |    2 +-
 drivers/net/sfc/mcdi.c                    |    5 +-
 drivers/net/sfc/selftest.c                |    8 ++-
 drivers/net/tg3.c                         |   27 ++++++---
 drivers/net/tg3.h                         |    3 +
 drivers/net/wireless/ath/ath5k/eeprom.c   |   32 +++++++++-
 drivers/net/wireless/ath/ath5k/eeprom.h   |    8 +++
 drivers/net/wireless/ath/ath9k/Kconfig    |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h    |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.c   |   45 ++++++++------
 drivers/net/wireless/iwlwifi/iwl-dev.h    |    2 +-
 drivers/net/wireless/mwl8k.c              |    4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2x00.h      |    6 ++
 drivers/net/wireless/rt2x00/rt2x00dev.c   |   12 +++-
 drivers/net/wireless/rt2x00/rt2x00queue.c |    6 +-
 drivers/net/wireless/zd1211rw/zd_mac.c    |   13 ++--
 include/net/ip.h                          |    2 +-
 net/ipv6/exthdrs.c                        |    7 ++-
 net/mac80211/iface.c                      |   47 +++++++++++++-
 net/mac80211/mlme.c                       |    8 ++-
 net/mac80211/rx.c                         |    8 ++-
 net/mac80211/scan.c                       |   10 ++--
 net/mac80211/tx.c                         |    5 +-
 net/mac80211/util.c                       |   12 ++++
 net/mac80211/wme.c                        |   96 +++++++++++++++++++++--------
 net/mac80211/wme.h                        |    8 ++-
 net/wireless/core.c                       |    4 +-
 net/wireless/reg.c                        |    2 +-
 52 files changed, 388 insertions(+), 212 deletions(-)
