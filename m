From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6.26 2008-03-25
Date: Tue, 25 Mar 2008 17:15:57 -0400
Message-ID: <20080325211557.GA20488@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4756 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732AbYCYVhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 17:37:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest package of wireless changes for 2.6.26.  Included are
libertas and iwlwifi driver updates, some mac80211 updates, a few rt2x00
driver updates, and a handful of odds and ends.

There will be one minor merge conflict in drivers/net/wireless/b43/dma.c
when you merge this with the 2.6.25 fixes I posted yesterday.  Just
take both sets of changes -- it is pretty obvious.

Please let me know if there are any problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org//pub/linux/kernel/people/linville/wireless-2.6.26

---

The following changes since commit 06802a819a0a2d31c952c0624cea6cd00e4e50da:
  David S. Miller (1):
        Merge branch 'master' of ../net-2.6/

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.26.git master

Al Viro (1):
      ipw2200 annotations and fixes

Assaf Krauss (6):
      iwlwifi: Re-ordering probe flow (4965)
      iwlwifi: Packing all 4965 parameters
      iwlwifi: Probe Flow - Performing allocation in a separate function
      iwlwifi: Probe Flow - Extracting hw and priv init
      iwlwifi: rename iwl4965_get_channel_info to iwl_get_channel_info
      iwlwifi: Completing the parameter packaging

Emmanuel Grumbach (6):
      iwlwifi-2.6: Cleans up set_key flow
      iwlwifi-2.6: RX status translation to old scheme
      mac80211: get a TKIP phase key from skb
      mac80211: allows driver to request a Phase 1 RX key
      iwlwifi-2.6: enables HW TKIP encryption
      iwlwifi-2.6: enables RX TKIP decryption in HW

Holger Schurig (9):
      libertas: convert CMD_MAC_CONTROL to a direct command
      libertas: rename packetfilter to mac_control
      libertas: remove some unused commands
      libertas: make a handy lbs_cmd_async() command
      libertas: fix scheduling while atomic bug in CMD_MAC_CONTROL
      libertas: convert GET_LOG to a direct command
      libertas: misc power saving adjusts
      libertas: remove lots of unused stuff
      libertas: store rssi as an u32

Ivo van Doorn (3):
      rt2x00: Add dev_flags to rx descriptor
      rt2x00: Fix rate detection for invalid signals
      rt2x00: Fix in_atomic() usage

Johannes Berg (3):
      wireless: add wiphy channel freq to channel struct lookup helper
      mac80211: use ieee80211_get_channel
      mac80211: filter scan results on unusable channels

Masakazu Mokuno (1):
      PS3: gelic: Add support for separate cipher selection

Max Stepanov (1):
      iwlwifi: Bug fix, CCMP with HW encryption with AGG

Michael Buesch (1):
      b43: Don't compile N-PHY code when N-PHY is disabled

Mohamed Abbas (1):
      mac80211: prevent tuning during scanning

Reinette Chatre (1):
      iwlwifi: remove macros containing offsets from eeprom struct

Ron Rindjunsky (3):
      mac80211: fixing delba debug print
      mac80211: fixing debug prints for AddBA request
      mac80211: tear down of block ack sessions

Tomas Winkler (6):
      iwlwifi: rename iwl-4965-debug.h back to iwl-debug.h
      iwlwifi: rename struct iwl4965_priv to struct iwl_priv
      iwlwifi: Add TX/RX statistcs to driver
      iwlwifi: Add debugfs to iwl core
      iwlwifi: iwl3945 remove 4965 commands
      iwlwifi: move host command sending functions to core module

Vladimir Koutny (1):
      mac80211: configure default wmm params correctly

 drivers/net/ps3_gelic_wireless.c                   |    2 +-
 drivers/net/wireless/b43/Makefile                  |    4 +-
 drivers/net/wireless/b43/nphy.h                    |   40 +
 drivers/net/wireless/ipw2200.c                     |   12 +-
 drivers/net/wireless/ipw2200.h                     |  112 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    8 +-
 drivers/net/wireless/iwlwifi/Makefile              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h   |   39 -
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |   32 -
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h   |   28 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |    3 -
 drivers/net/wireless/iwlwifi/iwl-4965-io.h         |   94 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c         |   53 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |  560 ++++---
 drivers/net/wireless/iwlwifi/iwl-4965.h            |  210 ++--
 drivers/net/wireless/iwlwifi/iwl-core.c            |  216 +++-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   55 +
 .../iwlwifi/{iwl-4965-debug.h => iwl-debug.h}      |   55 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  319 ++++
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  368 ++++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   58 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |  251 +++
 drivers/net/wireless/iwlwifi/iwl4965-base.c        | 1729 +++++++-------------
 drivers/net/wireless/libertas/11d.c                |   16 +-
 drivers/net/wireless/libertas/11d.h                |    5 +-
 drivers/net/wireless/libertas/assoc.c              |   16 +-
 drivers/net/wireless/libertas/cmd.c                |  254 +--
 drivers/net/wireless/libertas/cmd.h                |    9 +-
 drivers/net/wireless/libertas/cmdresp.c            |   66 +-
 drivers/net/wireless/libertas/debugfs.c            |    8 +-
 drivers/net/wireless/libertas/decl.h               |    5 +-
 drivers/net/wireless/libertas/dev.h                |    4 +-
 drivers/net/wireless/libertas/host.h               |    3 -
 drivers/net/wireless/libertas/hostcmd.h            |    7 +-
 drivers/net/wireless/libertas/if_cs.c              |    3 +
 drivers/net/wireless/libertas/join.c               |    9 +-
 drivers/net/wireless/libertas/join.h               |    9 +-
 drivers/net/wireless/libertas/main.c               |   35 +-
 drivers/net/wireless/libertas/scan.c               |    4 +-
 drivers/net/wireless/libertas/scan.h               |    7 +-
 drivers/net/wireless/libertas/wext.c               |   40 +-
 drivers/net/wireless/rt2x00/Kconfig                |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   99 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |  110 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |  127 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   11 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   10 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   15 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   57 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   22 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  114 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |  131 +-
 include/net/mac80211.h                             |   47 +
 include/net/wireless.h                             |    6 +
 net/mac80211/ieee80211.c                           |    7 +-
 net/mac80211/ieee80211_i.h                         |    2 +
 net/mac80211/ieee80211_ioctl.c                     |   31 +-
 net/mac80211/ieee80211_sta.c                       |  125 +-
 net/mac80211/tkip.c                                |   68 +-
 net/mac80211/tkip.h                                |    2 +-
 net/mac80211/wpa.c                                 |    2 +-
 net/wireless/util.c                                |   23 +
 62 files changed, 3199 insertions(+), 2568 deletions(-)
 rename drivers/net/wireless/iwlwifi/{iwl-4965-debug.h => iwl-debug.h} (82%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-debugfs.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-hcmd.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26-2008-03-25.patch.bz2

-- 
John W. Linville
linville@tuxdriver.com
