From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 19 Jan 2011 18:04:18 -0800 (PST)
Message-ID: <20110119.180418.216749267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Revert a netlink flag sanity check that is causing regressions in
   existing applications.

2) can_checksum_protocol() args were swapped, causing broken ipv6
   checksum handling with devices that cannot offload ipv6 checksums.
   Regression fix from Eric Dumazet.

3) CAN protocol sendmsg() doesn't validate sockaddr size, fix from
   Kurt Van Dijck.

4) Name space creation spams logs with useless ipv6 private extension
   messages, fix from Romain Francoise.

5) sctp SACK timer socket option is not properly named, but since it's
   been wrong for a long time provide a back-compat cpp define as well
   so we don't break existing apps.  Fix from Shan Wei.

6) NETIF_F_HW_VLAN_TX accidently masked out in network device offloading
   feature tests, regression fix from Jesse Gross.

7) iwmc3200wifi accidently returns ERR_PTR(0) on allocation failures,
   fix from Axel Lin.

8) rt2x00 leaks memory in firmware request error path, from Jesper Juhl.

9) Make IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK definition match spec, from
   Amitkumar Karwar.

10) Fix erroneous lockdep warnings in mac80211, from Johannes Berg.

11) In mac80211 aggregate code, handle black ack parameter of zero correctly,
    which means we should use maximum supported number of sub-frames.  Fix
    from Luciano Coelho.

12) Missing allocation failure checks in batman-adv meshing code, fix from
    Jesper Juhl.

13) TX checksumming bug fix in qeth from Frank Blaschka.

14) Fix error checking in cfcnfg_disconn_adapt_layer() CAIF protocol
    code, from Dan Carpenter.

15) vmxnet driver bug fixes from Shreyas Bhatewara, Guolin Yang,
    Matthieu Bucchianeri, and Dmitry Torokhov:
    1) Wrong variable used in ring size updates.
    2) ifconfig set MAC address setting gets lost
    3) NAPI needs to be disabled/enabled across suspend/resume.
    4) Command register access needs locking
    5) Too many MSI-X vectors allocated in single TX single RX queue case

16) Endianness fixes in ath9k_htc driver from Rajkumar Manoharan.

17) tx_complete_poll_work locking fix in ath5k driver from Bob Copeland.

18) iwlwifi EEPROM reading fix from Wey-Yi Guy.

19) LED, microcode loading, and duplex setting fixes for bnx2x from
    Yaniv Rosner and Eilon Greenstein.

20) ns83820 driver checks wrong pointer for NULL after alloc_etherdev(),
    fix from Jesper Juhl.

Please pull, thanks a lot!

The following changes since commit c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470:

  Linux 2.6.38-rc1 (2011-01-18 15:14:02 -0800)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Orishko (1):
      USB CDC NCM: tx_fixup() race condition fix

Amitkumar Karwar (1):
      ieee80211: correct IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK macro

Anton Vorontsov (1):
      gianfar: Fix misleading indentation in startup_gfar()

Axel Lin (1):
      iwmc3200wifi: Return proper error for iwm_if_alloc

Bob Copeland (1):
      ath5k: fix locking in tx_complete_poll_work

Dan Carpenter (1):
      caif: checking the wrong variable

David S. Miller (3):
      Merge branch 'for-david' of git://git.open-mesh.org/ecsv/linux-merge
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Revert "netlink: test for all flags of the NLM_F_DUMP composite"

Eric Dumazet (1):
      net: fix can_checksum_protocol() arguments swap

Frank Blaschka (1):
      qeth: l3 hw tx csum circumvent hw bug

Jesper Juhl (3):
      rt2x00: Don't leak mem in error path of rt2x00lib_request_firmware()
      batman-adv: Even Batman should not dereference NULL pointers
      ns83820: Avoid bad pointer deref in ns83820_init_one().

Jesse Gross (1):
      net offloading: Do not mask out NETIF_F_HW_VLAN_TX for vlan.

Johannes Berg (1):
      mac80211: fix lockdep warning

Kuninori Morimoto (1):
      net/irda/sh_irda: return to RX mode when TX error

Kurt Van Dijck (1):
      can: test size of struct sockaddr in sendmsg

Luciano Coelho (1):
      mac80211: use maximum number of AMPDU frames as default in BA RX

Luis R. Rodriguez (1):
      ath9k_hw: ASPM interoperability fix for AR9380/AR9382

Rajkumar Manoharan (2):
      ath9k_htc: Fix endian issue in tx header
      ath9k_hw: do PA offset calibration only on longcal interval

Romain Francoise (1):
      ipv6: Silence privacy extensions initialization

Shan Wei (1):
      sctp: user perfect name for Delayed SACK Timer option

Shreyas Bhatewara (8):
      vmxnet3: fix ring size update
      vmxnet3: Preserve the MAC address configured by ifconfig
      vmxnet3: Enable HW Rx VLAN stripping by default
      vmxnet3: Provide required number of bytes in first SG buffer
      vmxnet3: Make ethtool handlers multiqueue aware
      vmxnet3: Disable napi in suspend, reenable in resume.
      vmxnet3: Add locking for access to command register
      vmxnet3: Dont allocate extra MSI-x vectors

Sven Eckelmann (1):
      batman-adv: Use "__attribute__" shortcut macros

Ursula Braun (1):
      qeth: postpone open till recovery is finished

Wey-Yi Guy (1):
      iwlwifi: fix valid chain reading from EEPROM

Yaniv Rosner (8):
      bnx2x: Swap BCM8073 PHY polarity if required
      bnx2x: Common init will be executed only once after POR
      bnx2x: LED fix for BCM8727 over BCM57712
      bnx2x: Fix BCM8073/BCM8727 microcode loading
      bnx2x: Mark full duplex on some external PHYs
      bnx2x: Fix BCM84823 LED behavior
      bnx2x: Fix AER setting for BCM57712
      bnx2x: Update bnx2x version to 1.62.00-4

 drivers/net/bnx2x/bnx2x.h                          |    4 +-
 drivers/net/bnx2x/bnx2x_hsi.h                      |    4 +
 drivers/net/bnx2x/bnx2x_link.c                     |  173 ++++++++++---
 drivers/net/bnx2x/bnx2x_reg.h                      |    4 +
 drivers/net/gianfar.c                              |    2 +-
 drivers/net/irda/sh_irda.c                         |   14 +-
 drivers/net/ns83820.c                              |    5 +-
 drivers/net/usb/cdc_ncm.c                          |   19 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                  |   93 +++++---
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |  274 ++++++++++++--------
 drivers/net/vmxnet3/vmxnet3_int.h                  |    7 +-
 drivers/net/wireless/ath/ath5k/base.c              |    4 +
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   10 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    4 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |    2 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c         |    2 +
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    1 +
 drivers/s390/net/qeth_l2_main.c                    |   18 ++-
 drivers/s390/net/qeth_l3_main.c                    |   22 ++-
 include/linux/ieee80211.h                          |    2 +-
 include/net/sctp/user.h                            |    1 +
 net/batman-adv/main.h                              |    6 +-
 net/batman-adv/packet.h                            |   14 +-
 net/batman-adv/types.h                             |    4 +-
 net/batman-adv/unicast.c                           |    6 +-
 net/caif/cfcnfg.c                                  |    9 +-
 net/can/bcm.c                                      |    3 +
 net/can/raw.c                                      |    3 +
 net/core/dev.c                                     |    6 +-
 net/core/rtnetlink.c                               |    2 +-
 net/ipv4/inet_diag.c                               |    2 +-
 net/ipv6/addrconf.c                                |    3 -
 net/mac80211/agg-rx.c                              |   11 +-
 net/mac80211/main.c                                |   12 +-
 net/netfilter/nf_conntrack_netlink.c               |    4 +-
 net/netlink/genetlink.c                            |    2 +-
 net/sctp/socket.c                                  |    4 +-
 net/xfrm/xfrm_user.c                               |    2 +-
 41 files changed, 512 insertions(+), 258 deletions(-)
