From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 30 May 2012 18:37:19 -0400 (EDT)
Message-ID: <20120530.183719.1221974908629116025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several bug fixes, of note:

1) Fix IPSEC header length calculation for transport mode in ESP.
   The issue is whether to do the calculation before or after
   alignment.  Fix from Benjamin Poirier.

2) Fix regression in IPV6 IPSEC fragment length calculations, from Gao
   Feng.  This is another transport vs. tunnel mode issue.

3) Handle AF_UNSPEC connect()s properly in L2TP to avoid OOPSes.
   Fix from James Chapman.

4) Fix USB ASIX driver's reception of full sized VLAN packets, from
   Eric Dumazet.

5) Allow drop monitor (and, more generically, all generic netlink
   protocols) to be automatically loaded as a module.  From Neil
   Horman.

Please pull, thanks a lot!

The following changes since commit af56e0aa35f3ae2a4c1a6d1000702df1dd78=
cb76:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/sage/ceph-client =
(2012-05-30 11:17:19 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Benjamin Poirier (1):
      xfrm: take net hdr len into account for esp payload size calculat=
ion

Bj=F8rn Mork (1):
      net: qmi_wwan: Add Sierra Wireless device IDs

Claudio Pisa (1):
      mac80211: fix flag check for QoS NOACK frames

Dan Carpenter (1):
      NFC: potential integer overflow problem in check_crc()

David Woodhouse (1):
      solos-pci: Fix DMA support

Devendra Naga (2):
      r6040: disable pci device if the subsequent calls (after pci_enab=
le_device) fails
      r6040: Do a Proper deinit at errorpath and also when driver unloa=
ds (calling r6040_remove_one)

Emmanuel Grumbach (1):
      iwlwifi: fix the Transmit Frame Descriptor rings

Eric Dumazet (1):
      asix: allow full size 8021Q frames to be received

Eyal Shapira (2):
      wlcore: fix undefined symbols when CONFIG_PM is not defined
      mac80211: fix ADDBA declined after suspend with wowlan

=46elix Fietkau (6):
      ath5k: add possible wiphy interface combinations
      ath9k: stop rx dma before stopping tx
      ath9k: fix a use-after-free-bug when ath_tx_setup_buffer() fails
      ath9k_hw: update AR933x initvals to fix issues with high power de=
vices
      ath9k_hw: apply internal regulator settings on AR933x
      skb: avoid unnecessary reallocations in __skb_cow

Gao feng (1):
      ipv6: fix incorrect ipsec fragment

Grazvydas Ignotas (1):
      wl1251: fix oops on early interrupt

Hauke Mehrtens (1):
      brcmfmac: use vmalloc to allocate mem for the firmware

James Chapman (1):
      l2tp: fix oops in L2TP IP sockets for connect() AF_UNSPEC case

Joe Perches (2):
      net/wanrouter: Deprecate and schedule for removal
      netdevice: Update netif_dbg for CONFIG_DYNAMIC_DEBUG

Johannes Berg (2):
      iwlwifi: remove ucode16 option
      iwlwifi: fix memory leak if opmode fails to init

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Lee Jones (1):
      net/smsc911x: Repair broken failure paths

Meenakshi Venkataraman (3):
      iwlwifi: update BT traffic load states correctly
      iwlwifi: do not use shadow registers by default
      iwlwifi: do not send lq cmd when station add fails

Michael S. Tsirkin (1):
      virtio-net: remove useless disable on freeze

Neil Horman (3):
      net: add MODULE_ALIAS_NET_PF_PROTO_NAME
      genetlink: Build a generic netlink family module alias
      drop_monitor: Add module alias to enable automatic module loading

Simon Graham (1):
      xen/netback: Calculate the number of SKB slots required correctly

Soumik Das (1):
      mac80211: Fix race in checking AP status by sending null frame

Thadeu Lima de Souza Cascardo (1):
      rds_rdma: don't assume infiniband device is PCI

Yoshihiro Shimoda (1):
      net: sh_eth: fix the rxdesc pointer when rx descriptor empty happ=
ens

jamal (1):
      MAINTAINERS

 Documentation/feature-removal-schedule.txt         |    6 +
 MAINTAINERS                                        |    2 +-
 drivers/atm/solos-pci.c                            |    4 +-
 drivers/net/ethernet/rdc/r6040.c                   |   15 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    8 +-
 drivers/net/ethernet/smsc/smsc911x.c               |    7 +-
 drivers/net/usb/asix.c                             |    3 +-
 drivers/net/usb/qmi_wwan.c                         |    2 +
 drivers/net/virtio_net.c                           |    5 -
 drivers/net/wireless/ath/ath5k/base.c              |   19 ++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    3 +
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   |  178 ++++++------
 drivers/net/wireless/ath/ath9k/hw.c                |    3 +
 drivers/net/wireless/ath/ath9k/main.c              |    7 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   16 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    5 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    8 -
 drivers/net/wireless/iwlwifi/Makefile              |    1 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   18 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |  288 ------------=
--------
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |  129 ---------
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |   22 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    4 +-
 drivers/net/wireless/ti/wl1251/sdio.c              |    2 +-
 drivers/net/wireless/ti/wl1251/spi.c               |    3 +-
 drivers/net/wireless/ti/wlcore/acx.c               |    2 +
 drivers/net/wireless/ti/wlcore/acx.h               |    4 +-
 drivers/net/wireless/ti/wlcore/rx.c                |    2 +
 drivers/net/xen-netback/netback.c                  |    3 +-
 drivers/nfc/pn544_hci.c                            |    2 +-
 include/linux/genetlink.h                          |    3 +
 include/linux/net.h                                |    3 +
 include/linux/netdevice.h                          |    8 +-
 include/linux/skbuff.h                             |    2 -
 include/net/dst.h                                  |    1 +
 net/core/drop_monitor.c                            |    1 +
 net/ipv4/esp4.c                                    |   24 +-
 net/ipv6/esp6.c                                    |   18 +-
 net/ipv6/ip6_output.c                              |   68 ++++--
 net/l2tp/l2tp_ip.c                                 |   24 ++-
 net/l2tp/l2tp_ip6.c                                |   18 ++-
 net/l2tp/l2tp_netlink.c                            |    3 +-
 net/mac80211/mlme.c                                |    3 +-
 net/mac80211/tx.c                                  |    2 +-
 net/mac80211/util.c                                |   12 +-
 net/netlink/genetlink.c                            |    2 +-
 net/rds/ib.h                                       |    3 +-
 net/wanrouter/Kconfig                              |    2 +-
 net/xfrm/xfrm_policy.c                             |    3 +
 55 files changed, 343 insertions(+), 645 deletions(-)
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.h
