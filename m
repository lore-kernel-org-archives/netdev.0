From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 03 Jun 2011 17:08:08 -0700 (PDT)
Message-ID: <20110603.170808.79347365019246680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the first batch of networking bug fixes after -rc1:

1) TG3 iterates one too many frags when doing DMA unmaps,
   fix from Matt Carlson based upon a report by Alex
   Williamson.

2) net_dev_xmit tracepoint uses SKB after it may have been
   freed up, fix from Koki Sanagi.

3) flexcan and davinci_emac drivers missing clk_put(), fix from Julia
   Lawall.

4) RTNL locking race fix in CAIF protocol, from Sjur Br=A9=A1ndeland.

5) Validate family of sockaddr in ipv4 bind(), from Marcus Meissner.

6) Packet capture reports VLAN ID but doesn't indicate whether there
   was really a VLAN header there.  This is important because VLAN ID
   0 is legitimate.  Add a TP_STATUS_* flag to indicate this state,
   from Ben Greear.

7) Fix stats update locking bug in vlan_dev_hard_start_xmit(), from
   Wei Yongjun.

8) Add missing ->reset_resume() to cdc_ncm USB net driver.  From
   Stefan Metzmacher.

9) Fix broken handling of even header lengths in mwifiex driver,
   from Yogesh Ashok Powar.

10) Don't panic on RX buffer alloc failure in rtlwifi, from Larry
    Finger.

11) Fix oops in sched_scan of wl12xx driver, from Luciano Coelho.

12) Fix zs1211rw with OHCI controllers, from Jussi Kivilinna.

13) Fix under-allocation of SKB buffer space when receiving in PIO
    mode of ks8842 driver.  From Dennis Aberilla.

14) Pending timer and queue purging fix in SCTP from Wei Yongjun.

15) catc USB driver does GFP_KERNEL alloc with locks held, fix from
    Alexey Khoroshilov.

16) Revert an attempt to fix some section mismatches, it causes new
    problems.

17) Locking in l2cap_global_chan_by_psm() is busted, using read_unlock_=
bh()
    when should be using plain read_unlock().  Fix from Johannes Berg.

Please pull, thanks a lot!

The following changes since commit 4f1ba49efafccbc73017f824efa2505c81b2=
47cd:

  Merge branch 'for-linus' of git://git.kernel.dk/linux-block (2011-06-=
04 08:11:26 +0900)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Chadd (1):
      ath9k: Fix AR9287 calibration

Alexey Khoroshilov (1):
      drivers/net/usb/catc.c: Fix potential deadlock in catc_ctrl_run()

Ben Greear (1):
      af-packet: Add flag to distinguish VID 0 from no-vlan.

Chris Metcalf (1):
      ip_options_compile: properly handle unaligned pointer

Daniel Drake (1):
      libertas: Set command sequence number later to ensure consistency

Daniel Halperin (1):
      ath9k: fix two more bugs in tx power

David S. Miller (1):
      Revert "net: fix section mismatches"

Dennis Aberilla (1):
      drivers/net: ks8842 Fix crash on received packet when in PIO mode=
=2E

Eliad Peller (2):
      mac80211: clear local->ps_data on disassoc
      cfg80211: don't drop p2p probe responses

Jesper Juhl (1):
      mac80211: Remove duplicate linux/slab.h include from net/mac80211=
/scan.c

Johannes Berg (1):
      bluetooth l2cap: fix locking in l2cap_global_chan_by_psm

John W. Linville (2):
      Merge git://git.kernel.org/.../linville/wireless-next-2.6 into fo=
r-davem
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6 into for-davem

Julia Lawall (2):
      drivers/net/davinci_emac.c: add missing clk_put
      drivers/net/can/flexcan.c: add missing clk_put

Jussi Kivilinna (1):
      zd1211rw: fix to work on OHCI

Koki Sanagi (1):
      net: tracepoint of net_dev_xmit sees freed skb and causes panic

Larry Finger (2):
      rtlwifi: Fix kernel panic resulting from RX buffer allocation fai=
lure
      rtlwifi: Use order 2 RX buffer allocation only if necessary

Luciano Coelho (5):
      nl80211: fix check for valid SSID size in scan operations
      wl12xx: fix passive and radar channel generation for scheduled sc=
an
      wl12xx: fix DFS channels handling in scheduled scan
      wl12xx: add separate config value for DFS dwell time on sched sca=
n
      wl12xx: fix oops in sched_scan when forcing a passive scan

Marcus Meissner (1):
      net/ipv4: Check for mistakenly passed in non-IPv4 address

Mark Brown (1):
      net: dm9000: Get the chip in a known good state before enabling i=
nterrupts

Matt Carlson (1):
      tg3: Fix tg3_skb_error_unmap()

Rafa=A9=A9 Mi=A9=A9ecki (1):
      b43: N-PHY: initialize last var in calibration function

Rajkumar Manoharan (4):
      ath9k: Reset chip on baseband hang
      ath9k_hw: disable phy restart on baseband panic caused by RXSM
      ath9k: set 40 Mhz rate only if hw is configured in ht40
      mac80211: stop queues before rate control updation

Stanislaw Gruszka (2):
      iwl4965: fix 5GHz operation
      iwl4965: correctly validate temperature value

Stefan Metzmacher (1):
      usbnet/cdc_ncm: add missing .reset_resume hook

Tao Ma (1):
      wireless: Default to 'n' for 2 new added devices in Kconfig.

Wei Yongjun (2):
      sctp: stop pending timers and purge queues when peer restart asoc
      vlan: fix typo in vlan_dev_hard_start_xmit()

Wey-Yi Guy (1):
      iwlagn: fix incorrect PCI subsystem id for 6150 devices

Yogesh Ashok Powar (1):
      mwifiex: correct event header length

sjur.brandeland@stericsson.com (1):
      caif: Fix race when conditionally taking rtnl lock

 drivers/net/3c509.c                            |   14 +++---
 drivers/net/3c59x.c                            |    4 +-
 drivers/net/can/flexcan.c                      |    5 +-
 drivers/net/davinci_emac.c                     |   10 +++--
 drivers/net/depca.c                            |   35 ++++++++--------
 drivers/net/dm9000.c                           |    6 +-
 drivers/net/hp100.c                            |   12 +++---
 drivers/net/ibmlana.c                          |    4 +-
 drivers/net/irda/smsc-ircc2.c                  |   44 ++++++++++------=
----
 drivers/net/ks8842.c                           |    2 +-
 drivers/net/ne3210.c                           |   15 +++----
 drivers/net/smc-mca.c                          |    6 +-
 drivers/net/tg3.c                              |    2 +-
 drivers/net/tokenring/madgemc.c                |    2 +-
 drivers/net/tulip/de4x5.c                      |    4 +-
 drivers/net/usb/catc.c                         |    2 +-
 drivers/net/usb/cdc_ncm.c                      |    3 +-
 drivers/net/wireless/ath/ath9k/Kconfig         |    1 -
 drivers/net/wireless/ath/ath9k/ar9002_calib.c  |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   10 ++++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |   22 ++++++++++
 drivers/net/wireless/ath/ath9k/eeprom_9287.c   |   10 ++++-
 drivers/net/wireless/ath/ath9k/hw.c            |    5 ++-
 drivers/net/wireless/ath/ath9k/hw.h            |    2 +
 drivers/net/wireless/ath/ath9k/main.c          |    4 +-
 drivers/net/wireless/ath/ath9k/rc.c            |    3 +-
 drivers/net/wireless/b43/phy_n.c               |    2 +-
 drivers/net/wireless/iwlegacy/iwl-4965-lib.c   |    4 +-
 drivers/net/wireless/iwlegacy/iwl-4965.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   28 ++++++++----
 drivers/net/wireless/iwlwifi/iwl-agn.c         |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h         |    1 +
 drivers/net/wireless/libertas/cmd.c            |    6 +-
 drivers/net/wireless/mwifiex/sdio.h            |    4 +-
 drivers/net/wireless/rt2x00/Kconfig            |    1 -
 drivers/net/wireless/rtlwifi/pci.c             |   35 ++++++++++------
 drivers/net/wireless/wl12xx/conf.h             |    3 +
 drivers/net/wireless/wl12xx/main.c             |    1 +
 drivers/net/wireless/wl12xx/scan.c             |   49 +++++++++++++++-=
------
 drivers/net/wireless/wl12xx/scan.h             |    3 +
 drivers/net/wireless/zd1211rw/zd_usb.c         |   53 ++++++++++++++++=
+++-----
 include/linux/ieee80211.h                      |    8 +++-
 include/linux/if_packet.h                      |    1 +
 include/net/sctp/command.h                     |    1 +
 include/net/sctp/structs.h                     |    2 +-
 include/trace/events/net.h                     |   12 +++--
 net/8021q/vlan_dev.c                           |    2 +-
 net/bluetooth/l2cap_core.c                     |    2 +-
 net/caif/chnl_net.c                            |    9 +---
 net/core/dev.c                                 |    7 ++-
 net/ipv4/af_inet.c                             |    3 +
 net/ipv4/ip_options.c                          |   15 ++++---
 net/mac80211/mlme.c                            |    7 +++
 net/mac80211/scan.c                            |    1 -
 net/packet/af_packet.c                         |   15 +++++-
 net/sctp/associola.c                           |   23 ++++++----
 net/sctp/sm_sideeffect.c                       |    3 +
 net/sctp/sm_statefuns.c                        |   14 +++++-
 net/wireless/nl80211.c                         |    4 +-
 net/wireless/scan.c                            |   43 +++++++++++-----=
---
 60 files changed, 380 insertions(+), 219 deletions(-)
