From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 09 May 2017 16:03:35 -0400 (EDT)
Message-ID: <20170509.160335.1354364643862943360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix multiqueue in stmmac driver on PCI, from Andy Shevchenko.

2) cdc_ncm doesn't actually fully zero out the padding area is
   allocates on TX, from Jim Baxter.

3) Don't leak map addresses in BPF verifier, from Daniel Borkmann.

4) If we randomize TCP timestamps, we have to do it everywhere
   including SYN cookies.  From Eric Dumazet.

5) Fix "ethtool -S" crash in aquantia driver, from Pavel Belous.

6) Fix allocation size for ntp filter bitmap in bnxt_en driver,
   from Dan Carpenter.

7) Add missing memory allocation return value check to DSA loop
   driver, from Christophe Jaillet.

8) Fix XDP leak on driver unload in qed driver, from Suddarsana Reddy
   Kalluru.

9) Don't inherit MC list from parent inet connection sockets,
   another syzkaller spotted gem.  Fix from Eric Dumazet.

Please pull, thanks a lot.

The following changes since commit af82455f7dbd9dc20244d80d033721b30d22c065:

  Merge tag 'char-misc-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc (2017-05-04 19:15:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 657831ffc38e30092a2d5f03d385d710eb88b09a:

  dccp/tcp: do not inherit mc_list from parent (2017-05-09 15:17:49 -0400)

----------------------------------------------------------------
Andy Shevchenko (4):
      stmmac: pci: set default number of rx and tx queues
      stmmac: pci: TX and RX queue priority configuration
      stmmac: pci: RX queue routing configuration
      stmmac: pci: split out common_default_data() helper

Christophe Jaillet (1):
      net: dsa: loop: Check for memory allocation failure

Dan Carpenter (1):
      bnxt_en: allocate enough space for ->ntp_fltr_bmap

Daniel Borkmann (1):
      bpf: don't let ldimm64 leak map addresses on unprivileged

David S. Miller (5):
      Merge branch 'stmmac-pci-fix-crash-on-Intel-Galileo-Gen2'
      Merge tag 'mac80211-for-davem-2017-05-08' of git://git.kernel.org/.../jberg/mac80211
      Revert "ipv4: restore rt->fi for reference counting"
      Merge branch 'mlx4-misc-fixes'
      Merge branch 'qed-general-fixes'

Eric Dumazet (2):
      tcp: randomize timestamps on syncookies
      dccp/tcp: do not inherit mc_list from parent

Ganesh Goudar (1):
      cxgb4: avoid disabling FEC by default

Geliang Tang (2):
      net/hippi/rrunner: use memdup_user
      yam: use memdup_user

Grygorii Strashko (1):
      net: ethernet: ti: cpsw: adjust cpsw fifos depth for fullduplex flow control

Hangbin Liu (2):
      bonding: check nla_put_be32 return value
      vti: check nla_put_* return value

Jack Morgenstein (1):
      net/mlx4_core: Reduce harmless SRIOV error message to debug level

Jim Baxter (1):
      net: cdc_ncm: Fix TX zero padding

Johannes Berg (4):
      mac80211: properly remove RX_ENC_FLAG_40MHZ
      nl80211: correctly validate MU-MIMO groups
      mac80211: fix IBSS presp allocation size
      cfg80211: fix multi scheduled scan kernel-doc

Jon Mason (1):
      net: mdio-mux: bcm-iproc: call mdiobus_free() in error path

Kamal Heib (1):
      net/mlx4_en: Change the error print to debug print

Karim Eshapa (1):
      drivers: net: wimax: i2400m: i2400m-usb: Use time_after for time comparison

Kees Cook (4):
      bna: Avoid reading past end of buffer
      bna: ethtool: Avoid reading past end of buffer
      qlge: Avoid reading past end of buffer
      DECnet: Use container_of() for embedded struct

Luca Coelho (1):
      mac80211: bail out from prep_connection() if a reconfig is ongoing

Mintz, Yuval (3):
      qed: Fix VF removal sequence
      qed: Tell QM the number of tasks
      qede: Split PF/VF ndos.

Pavel Belous (1):
      aquantia: Fix "ethtool -S" crash when adapter down.

Rakesh Pandit (1):
      net: alx: handle pci_alloc_irq_vectors return correctly

Ram Amrani (1):
      qed: Correct doorbell configuration for !4Kb pages

Suddarsana Reddy Kalluru (1):
      qede: Fix XDP memory leak on unload

Talat Batheesh (1):
      net/mlx4_en: Avoid adding steering rules with invalid ring

Tobias Klauser (1):
      bridge: netlink: account for IFLA_BRPORT_{B, M}CAST_FLOOD size and policy

Vlad Yasevich (1):
      vlan: Keep NETIF_F_HW_CSUM similar to other software devices

WANG Cong (2):
      ipv4: restore rt->fi for reference counting
      ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf

Wei Wang (1):
      tcp: make congestion control optionally skip slow start after idle

 drivers/net/bonding/bond_netlink.c                    |  3 ++-
 drivers/net/dsa/dsa_loop.c                            |  3 +++
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c       |  6 ++++--
 drivers/net/ethernet/atheros/alx/main.c               |  4 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c             |  3 ++-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c            |  2 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c       |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h            |  9 +++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            | 38 +++++++++++++++++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h         |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/cmd.c              | 14 +++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c       |  5 +++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c            |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c             |  1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c             |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c            |  6 ++++--
 drivers/net/ethernet/qlogic/qede/qede_filter.c        |  5 -----
 drivers/net/ethernet/qlogic/qede/qede_main.c          | 25 ++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c           |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      | 41 ++++++++++++++++++-----------------------
 drivers/net/ethernet/ti/cpsw.c                        | 16 ++++++++++++++++
 drivers/net/hamradio/yam.c                            | 10 ++++------
 drivers/net/hippi/rrunner.c                           | 17 +++++++----------
 drivers/net/phy/mdio-mux-bcm-iproc.c                  |  5 ++++-
 drivers/net/usb/cdc_ncm.c                             | 11 +++++++----
 drivers/net/wimax/i2400m/i2400m-usb.h                 |  2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c           |  2 +-
 drivers/net/wireless/ath/ath9k/mac.c                  |  4 ++--
 drivers/net/wireless/intel/iwlegacy/4965-mac.c        |  4 +++-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c           |  4 +++-
 drivers/net/wireless/mac80211_hwsim.c                 |  8 +++++++-
 include/net/addrconf.h                                |  2 ++
 include/net/cfg80211.h                                |  2 +-
 include/net/mac80211.h                                |  2 --
 include/net/secure_seq.h                              | 10 ++++++----
 include/net/tcp.h                                     |  9 ++++++---
 kernel/bpf/verifier.c                                 | 21 ++++++++++++++++-----
 net/8021q/vlan_dev.c                                  | 13 ++++++++++---
 net/bridge/br_netlink.c                               |  4 ++++
 net/core/secure_seq.c                                 | 31 +++++++++++++++++++------------
 net/decnet/dn_neigh.c                                 | 12 ++++++------
 net/ipv4/inet_connection_sock.c                       |  2 ++
 net/ipv4/ip_vti.c                                     | 13 +++++++------
 net/ipv4/syncookies.c                                 | 12 ++++++++++--
 net/ipv4/tcp_input.c                                  |  8 +++-----
 net/ipv4/tcp_ipv4.c                                   | 32 +++++++++++++++++++-------------
 net/ipv4/tcp_output.c                                 |  4 +++-
 net/ipv6/addrconf.c                                   |  1 +
 net/ipv6/route.c                                      | 13 +++++++++++--
 net/ipv6/syncookies.c                                 | 10 +++++++++-
 net/ipv6/tcp_ipv6.c                                   | 32 +++++++++++++++++++-------------
 net/mac80211/ibss.c                                   |  2 ++
 net/mac80211/mlme.c                                   |  4 ++++
 net/wireless/nl80211.c                                |  4 ++--
 55 files changed, 345 insertions(+), 167 deletions(-)
