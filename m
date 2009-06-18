From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 18 Jun 2009 02:33:08 -0700 (PDT)
Message-ID: <20090618.023308.249354637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55846
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754887AbZFRJdF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 05:33:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Another round of networking stuff:

1) SKY2 driver fixes and updates from Stephen Hemminger

2) NetXEN bug fixes from Dhananjay Phadke

3) Wireless fixes via John Linville

4) E100 suspend/resume fix from Rafael J. Wysocki

5) UCC_GETH reverts from Grant Likely to fix some merge issues.

6) Kerneldoc fixes from Randy Dunlap

7) SIS190 and R8169 bug fixes from Fran=E7ois Romieu.

8) Those sk_wmem_alloc off-by-one fixes from Eric Dumazet.

9) X25 does sock_lock() (which sleeps) from timer, fix.

10) Sonic driver build fix.

There is a netfilter race that Ingo is still triggering that Eric
Dumazet and Patrick McHardy are working on a fix for.  There is also a
minor TCP issue that will result in a revert if we can't narrow it
down soon.

Please pull, thanks a lot!

The following changes since commit 03347e2592078a90df818670fddf97a33eec=
70fb:
  Linus Torvalds (1):
        Merge branch 'release' of git://git.kernel.org/.../aegl/linux-2=
=2E6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git ma=
ster

Abhijeet Kolekar (1):
      iwlwifi/iwl3945: fix suspend resume association bug

Andrey Yurovsky (1):
      libertas: fix IEEE PS mode in GSPI driver

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      x25: Fix sleep from timer on socket destroy.
      sonic: Fix build after ndo_start_xmit() changes.

Dhananjay Phadke (2):
      netxen: fix detection of cut-thru firmware mode
      netxen: fix tx ring accounting

Eric Dumazet (4):
      net: sk_wmem_alloc has initial value of one, not zero
      net: correct off-by-one write allocations reports
      atm: sk_wmem_alloc initial value is one
      forcedeth: fix dma api mismatches

Gabor Juhos (3):
      ath9k: restore power mode on error path
      ath9k: prevent sleeping while we are waiting for CAB
      ath9k: process rx packet if we are waiting for CAB

Grant Likely (1):
      Revert "net/ucc_geth: Add SGMII support for UEC GETH driver"

Haiying Wang (1):
      net/ucc_geth: Add SGMII support for UCC GETH driver

Jarek Poplawski (2):
      pkt_sched: Update drops stats in act_police
      ipv4: Fix fib_trie rebalancing, part 2

Jiri Pirko (1):
      net: group address list and its count

Johannes Berg (8):
      sony: fix rfkill code again
      iwlwifi: revamp bss_info_changed
      ath9k: port to cfg80211 rfkill
      mac80211: add queue debugfs file
      mac80211: disconnect when user changes channel
      rfkill: improve docs
      dell-laptop: fix rfkill conversion
      mac80211: fix wext bssid/ssid setting

Jouni Malinen (1):
      mac80211: Do not try to associate with an empty SSID

Nick Kossifidis (1):
      ath5k: fix mesh beaconing

Patrick McHardy (1):
      net: fix network drivers ndo_start_xmit() return values

Rafael J. Wysocki (1):
      Net / e100: Fix suspend of devices that cannot be power managed

Randy Dunlap (2):
      skbuff.h: fix skb_dst kernel-doc
      phy_device: fix parameter name in kernel-doc

Sebastian Andrzej Siewior (1):
      net/libertas: don't recursive spin lock in if_spi_e2h()

Sivakumar Subramani (1):
      vxge: Enable SRIOV support in the driver.

Stephen Hemminger (12):
      sky2: don't look for VPD size
      skbuff: skb_mac_header_was_set is always true on >32 bit
      skbuff: don't corrupt mac_header on skb expansion
      sky2: turn off pause during shutdown
      sky2: more receive shutdown
      sky2: PCI irq issues
      sky2: fix shutdown synchronization
      sky2: receive counter update
      sky2: reduce default transmit ring
      sky2: skb recycling
      sky2: add GRO support
      sky2: version 1.23

S=E9guier R=E9gis (1):
      via-velocity : fix no link detection on boot

Vasanthakumar Thiagarajan (2):
      ath9k: Add helper to get ath9k specific current channel
      ath9k: Make sure we have current channel in ah_curchan before rf =
disable/enable

Wey-Yi Guy (3):
      iwlwifi: checking for 40MHz mode
      iwlwifi: check control channel for pure 40MHz
      iwlwifi: check for channel location for 40MHz

chaithrika@ti.com (1):
      TI DaVinci EMAC : Fix rmmod error

fran=E7ois romieu (2):
      sis190: use an adequate phy list entry as a fallback
      r8169: do not bring device down when suspending

 Documentation/rfkill.txt                    |  137 ++++++++++++-------=
----
 drivers/isdn/i4l/isdn_net.c                 |    2 +-
 drivers/net/bnx2.c                          |    4 +-
 drivers/net/davinci_emac.c                  |    1 -
 drivers/net/e100.c                          |   11 +-
 drivers/net/e1000/e1000_main.c              |    4 +-
 drivers/net/forcedeth.c                     |   46 +++++---
 drivers/net/hamradio/bpqether.c             |    2 +-
 drivers/net/hp100.c                         |   35 +++---
 drivers/net/ixgbe/ixgbe_main.c              |    6 +-
 drivers/net/mv643xx_eth.c                   |    2 +-
 drivers/net/netxen/netxen_nic.h             |   11 ++-
 drivers/net/netxen/netxen_nic_hdr.h         |    1 +
 drivers/net/netxen/netxen_nic_hw.c          |    6 +-
 drivers/net/netxen/netxen_nic_init.c        |   11 +-
 drivers/net/netxen/netxen_nic_main.c        |   32 +++--
 drivers/net/niu.c                           |    4 +-
 drivers/net/phy/phy_device.c                |    2 +-
 drivers/net/r8169.c                         |   19 ++--
 drivers/net/sis190.c                        |    2 +-
 drivers/net/sky2.c                          |  161 ++++++++++++++++++-=
--------
 drivers/net/sky2.h                          |    1 +
 drivers/net/sonic.c                         |    2 +-
 drivers/net/ucc_geth.c                      |  113 ++++++++-----------
 drivers/net/ucc_geth.h                      |    2 +-
 drivers/net/via-velocity.c                  |    4 +-
 drivers/net/virtio_net.c                    |   10 +-
 drivers/net/vxge/vxge-config.c              |   12 +-
 drivers/net/vxge/vxge-main.c                |   13 ++
 drivers/net/vxge/vxge-version.h             |    4 +-
 drivers/net/wan/lapbether.c                 |   16 +--
 drivers/net/wireless/ath/ath5k/pcu.c        |    5 +-
 drivers/net/wireless/ath/ath9k/Kconfig      |    1 -
 drivers/net/wireless/ath/ath9k/ath9k.h      |   10 +--
 drivers/net/wireless/ath/ath9k/hw.c         |   29 ++---
 drivers/net/wireless/ath/ath9k/hw.h         |    3 -
 drivers/net/wireless/ath/ath9k/main.c       |  130 +++++++------------=
---
 drivers/net/wireless/ath/ath9k/recv.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.c     |  141 ++++++++++++++-----=
----
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/libertas/if_spi.c      |   11 +-
 drivers/platform/x86/dell-laptop.c          |    2 +-
 drivers/platform/x86/sony-laptop.c          |    5 +-
 drivers/s390/net/qeth_l2_main.c             |    2 +-
 include/linux/netdevice.h                   |   17 ++-
 include/linux/skbuff.h                      |    2 +-
 include/net/sock.h                          |   33 ++++++
 include/net/x25.h                           |    2 +-
 net/appletalk/atalk_proc.c                  |    4 +-
 net/appletalk/ddp.c                         |    9 +-
 net/atm/common.c                            |   12 +-
 net/atm/ioctl.c                             |    3 +-
 net/atm/proc.c                              |    4 +-
 net/atm/raw.c                               |    2 +-
 net/ax25/af_ax25.c                          |   14 +-
 net/bluetooth/af_bluetooth.c                |    2 +-
 net/core/dev.c                              |  130 ++++++++++---------=
--
 net/core/skbuff.c                           |   13 ++-
 net/decnet/af_decnet.c                      |    2 +-
 net/econet/af_econet.c                      |    6 +-
 net/ieee802154/dgram.c                      |    3 +-
 net/ipv4/fib_trie.c                         |   24 ++---
 net/ipv4/inet_diag.c                        |    4 +-
 net/ipv4/raw.c                              |    7 +-
 net/ipv4/udp.c                              |    7 +-
 net/ipv6/raw.c                              |    7 +-
 net/ipv6/udp.c                              |    4 +-
 net/ipx/af_ipx.c                            |    2 +-
 net/ipx/ipx_proc.c                          |    4 +-
 net/irda/af_irda.c                          |    3 +-
 net/key/af_key.c                            |    4 +-
 net/llc/llc_proc.c                          |    4 +-
 net/mac80211/debugfs.c                      |   25 ++++
 net/mac80211/ieee80211_i.h                  |    2 +-
 net/mac80211/mlme.c                         |   38 +++++--
 net/mac80211/util.c                         |   25 ----
 net/mac80211/wext.c                         |   31 +++++-
 net/netlink/af_netlink.c                    |    4 +-
 net/netrom/af_netrom.c                      |    9 +-
 net/packet/af_packet.c                      |    3 +-
 net/rose/af_rose.c                          |   10 +-
 net/sched/act_police.c                      |    4 +
 net/sched/em_meta.c                         |    4 +-
 net/sctp/socket.c                           |    4 +-
 net/unix/af_unix.c                          |    2 +-
 net/x25/af_x25.c                            |   30 ++++--
 net/x25/x25_proc.c                          |    4 +-
 net/x25/x25_timer.c                         |    2 +-
 89 files changed, 833 insertions(+), 713 deletions(-)
