From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-01-09
Date: Wed, 9 Jan 2013 14:18:18 -0500
Message-ID: <20130109191817.GA17321@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please pull this batch of fixes (and a new driver) for the 3.8 stream...

Included is a mac80211 pull, of which Johannes says the following:

'This includes a number of fixes for various pieces of mac80211. I've
also included Thomas's memory RMC hash table optimisation since it
saves so much memory.'

Also from Johannes is an iwlwifi pull:

'I have two fixes for iwlwifi: one to fix a lost return value that was
dropped in a previous patch and could cause "nobody cared" IRQ messages,
and one to work around a firmware issue.'

Amitkumar Karwar brings an mwifiex for a typo in an comparison.

Bing Zhao gives us an mwifiex fix to properly check the return value
from wait_event_interruptible and handle it properly.

Chen Gang provides a fix to make iwlegacy use strlcpy instead of
strncpy, avoiding a potential buffer underflow.

Julian Wollrath fixes a typo in an error message in rtlwifi.

Larry Finger brings a b43 fix for a firmware loading problem.

Nickolai Zeldovich avoids a use-after-free in the mwl8k driver.

Vladimir Kondratiev brings the last big piece, the new Qualcomm/Atheros
wil6210 802.11ad driver.  Since it is for new hardware, I hope that
taking it for 3.8 is not a problem.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit c9be4a5c49cf51cc70a993f004c5bb30067a65ce:

  net: prevent setting ttl=0 via IP_TTL (2013-01-08 17:57:10 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to a9b8a894ad7d0b90b0464c9ac7e8e5c1687edcae:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2013-01-09 11:01:37 -0500)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: fix typo in setting up ibss network parameters

Bing Zhao (1):
      mwifiex: check wait_event_interruptible return value

Chaitanya (1):
      mac80211: fix maximum MTU

Chen Gang (1):
      drivers/net/wireless/iwlegacy: use strlcpy instead of strncpy

Emmanuel Grumbach (1):
      iwlwifi: fix the reclaimed packet tracking upon flush queue

Felix Fietkau (1):
      mac80211: flush AP_VLAN stations when tearing down the BSS AP

Johannes Berg (5):
      mac80211: assign VLAN channel contexts
      mac80211: fix station destruction in AP/mesh modes
      mac80211: use del_timer_sync for final sta cleanup timer deletion
      mac80211: fix dtim_period in hidden SSID AP association
      iwlwifi: fix PCIe interrupt handle return value

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Julian Wollrath (1):
      rtlwifi: Fix typo in debug output of rtl8192c and rtl8723ae

Larry Finger (1):
      b43: Fix firmware loading when driver is built into the kernel

Nickolai Zeldovich (1):
      drivers/net/wireless/mwl8k.c: avoid use-after-free

Stanislaw Gruszka (1):
      mac80211: fix ibss scanning

Thomas Pedersen (1):
      mac80211: RMC buckets are just list heads

Vladimir Kondratiev (1):
      wireless: add new wil6210 802.11ad 60GHz driver

 MAINTAINERS                                        |    8 +
 drivers/net/wireless/ath/Kconfig                   |    1 +
 drivers/net/wireless/ath/Makefile                  |    1 +
 drivers/net/wireless/ath/wil6210/Kconfig           |   29 +
 drivers/net/wireless/ath/wil6210/Makefile          |   13 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  573 ++++++++++
 drivers/net/wireless/ath/wil6210/dbg_hexdump.h     |   30 +
 drivers/net/wireless/ath/wil6210/debugfs.c         |  603 +++++++++++
 drivers/net/wireless/ath/wil6210/interrupt.c       |  471 +++++++++
 drivers/net/wireless/ath/wil6210/main.c            |  407 +++++++
 drivers/net/wireless/ath/wil6210/netdev.c          |  157 +++
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |  223 ++++
 drivers/net/wireless/ath/wil6210/txrx.c            |  871 +++++++++++++++
 drivers/net/wireless/ath/wil6210/txrx.h            |  362 +++++++
 drivers/net/wireless/ath/wil6210/wil6210.h         |  363 +++++++
 drivers/net/wireless/ath/wil6210/wmi.c             |  975 +++++++++++++++++
 drivers/net/wireless/ath/wil6210/wmi.h             | 1116 ++++++++++++++++++++
 drivers/net/wireless/b43/b43.h                     |    5 +
 drivers/net/wireless/b43/main.c                    |   54 +-
 drivers/net/wireless/b43/main.h                    |    5 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |    2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   24 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c            |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   21 +-
 drivers/net/wireless/mwl8k.c                       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |    2 +-
 net/mac80211/cfg.c                                 |    2 +
 net/mac80211/chan.c                                |   38 +
 net/mac80211/ibss.c                                |    9 +-
 net/mac80211/ieee80211_i.h                         |   16 +-
 net/mac80211/iface.c                               |   48 +-
 net/mac80211/mesh.c                                |    8 +-
 net/mac80211/mesh.h                                |    2 +-
 net/mac80211/mlme.c                                |   75 +-
 net/mac80211/scan.c                                |   46 +-
 net/mac80211/sta_info.c                            |   46 +-
 net/mac80211/sta_info.h                            |    3 +-
 39 files changed, 6488 insertions(+), 130 deletions(-)
 create mode 100644 drivers/net/wireless/ath/wil6210/Kconfig
 create mode 100644 drivers/net/wireless/ath/wil6210/Makefile
 create mode 100644 drivers/net/wireless/ath/wil6210/cfg80211.c
 create mode 100644 drivers/net/wireless/ath/wil6210/dbg_hexdump.h
 create mode 100644 drivers/net/wireless/ath/wil6210/debugfs.c
 create mode 100644 drivers/net/wireless/ath/wil6210/interrupt.c
 create mode 100644 drivers/net/wireless/ath/wil6210/main.c
 create mode 100644 drivers/net/wireless/ath/wil6210/netdev.c
 create mode 100644 drivers/net/wireless/ath/wil6210/pcie_bus.c
 create mode 100644 drivers/net/wireless/ath/wil6210/txrx.c
 create mode 100644 drivers/net/wireless/ath/wil6210/txrx.h
 create mode 100644 drivers/net/wireless/ath/wil6210/wil6210.h
 create mode 100644 drivers/net/wireless/ath/wil6210/wmi.c
 create mode 100644 drivers/net/wireless/ath/wil6210/wmi.h
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
