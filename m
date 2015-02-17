From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 17 Feb 2015 10:48:41 -0800 (PST)
Message-ID: <20150217.104841.142476680181650880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Missing netlink attribute validation in nft_lookup, from Patrick
   McHardy.

2) Restrict ipv6 partial checksum handling to UDP, since that's the
   only case it works for.  From Vlad Yasevich.

3) Clear out silly device table sentinal macros used by SSB and BCMA
   drivers.  From Joe Perches.

4) Make sure the remote checksum code never creates a situation where
   the remote checksum is applied yet the tunneling metadata describing
   the remote checksum transformation is still present.  Otherwise
   an external entity might see this and apply the checksum again.
   From Tom Herbert.

5) Use msecs_to_jiffies() where applicable, from Nicholas Mc Guire.

6) Don't explicitly initialize timer struct fields, use setup_timer()
   and mod_timer() instead.  From Vaishali Thakkar.

7) Don't invoke tg3_halt() without the tp->lock held, from Jun'ichi
   Nomura.

8) Missing __percpu annotation in ipvlan driver, from Eric Dumazet.

9) Don't potentially perform skb_get() on shared skbs, also from
   Eric Dumazet.

10) Fix COW'ing of metrics for non-DST_HOST routes in ipv6, from
    Martin KaFai Lau.

11) Fix merge resolution error between the iov_iter changes in
    vhost and some bug fixes that occurred at the same time.
    From Jason Wang.

12) If rtnl_configure_link() fails we have to perform a call to
    ->dellink() before unregistering the device.  From WANG Cong.

Please pull, thanks a lot!

The following changes since commit 73b4f63aebd6d57db4ca1d31fa6f85166512=
07b0:

  Merge tag 'docs-for-linus' of git://git.lwn.net/linux-2.6 (2015-02-11=
 13:03:11 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 19334920eaf7df3f69950b040ede6c7598425a5b=
:

  net: dsa: Set valid phy interface type (2015-02-17 10:37:39 -0800)

----------------------------------------------------------------
Aleksander Morgado (1):
      hso: fix rx parsing logic when skb allocation fails

Arturo Borrero (1):
      netfilter: nft_compat: add ebtables support

David L Stevens (1):
      sunvnet: don't change gso data on clones

David S. Miller (3):
      Merge git://git.kernel.org/.../pablo/nf-next
      Merge branch 'rco_correctness'
      Merge tag 'wireless-drivers-for-davem-2015-02-11' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers

Eli Cohen (1):
      net/mlx5_core: Fix configuration of log_uar_page_sz

Eric Dumazet (2):
      ipvlan: add a missing __percpu pcpu_stats
      tcp: make sure skb is not shared before using skb_get()

Geert Uytterhoeven (3):
      openvswitch: Add missing initialization in validate_and_copy_set_=
tun()
      drivers: net: xgene: Make xgene_enet_of_match depend on CONFIG_OF
      bridge: netfilter: Move sysctl-specific error code inside #ifdef

Guenter Roeck (1):
      net: dsa: Set valid phy interface type

Jan Stancek (1):
      ipv6: fix possible deadlock in ip6_fl_purge / ip6_fl_gc

Jason Wang (1):
      vhost_net: fix wrong iter offset when setting number of buffers

Joe Perches (2):
      treewide: Remove unnecessary BCMA_CORETABLE_END macro
      treewide: Remove unnecessary SSB_DEVTABLE_END macro

Jun'ichi Nomura \(NEC\) (1):
      tg3: Hold tp->lock before calling tg3_halt() from tg3_init_one()

Larry Finger (1):
      rtlwifi: Remove logging statement that is no longer needed

Martin KaFai Lau (1):
      ipv6: fix ipv6_cow_metrics for non DST_HOST case

Masanari Iida (1):
      net/core: Fix warning while make xmldocs caused by dev.c

Michael Grzeschik (1):
      com20020-pci: add support for eae single card

Nicholas Mc Guire (1):
      et131x: use msecs_to_jiffies for conversions

Patrick McHardy (1):
      netfilter: nft_lookup: add missing attribute validation for NFTA_=
LOOKUP_SET_ID

Pravin B Shelar (2):
      openvswitch: Reset key metadata for packet execution.
      openvswitch: Fix key serialization.

Rafa=A9=A9 Mi=A9=A9ecki (1):
      bgmac: fix device initialization on Northstar SoCs (condition typ=
o)

Shahed Shaikh (1):
      qlcnic: Delete existing multicast MAC list before adding new

Sowmini Varadhan (1):
      rds: rds_cong_queue_updates needs to defer the congestion update =
transmission

Stephen Hemminger (1):
      net: spelling fixes

Sylvain Rochet (1):
      net: phy: micrel: disable NAND-tree for KSZ8021, KSZ8031, KSZ8051=
, KSZ8081

Tom Herbert (7):
      net: Fix remcsum in GRO path to not change packet
      net: Clarify meaning of CHECKSUM_PARTIAL for receive path
      udp: Set SKB_GSO_UDP_TUNNEL* in UDP GRO path
      net: Use more bit fields in napi_gro_cb
      net: Infrastructure for CHECKSUM_PARTIAL with remote checsum offl=
oad
      vxlan: Use checksum partial with remote checksum offload
      gue: Use checksum partial with remote checksum offload

Vaishali Thakkar (1):
      drivers/net: Use setup_timer and mod_timer

Vlad Yasevich (1):
      ipv6: Partial checksum only UDP packets

WANG Cong (1):
      rtnetlink: call ->dellink on failure when ->newlink exists

hayeswang (1):
      r8152: restore hw settings

 drivers/net/arcnet/com20020-pci.c                        |   21 ++++++=
++++++++++++---
 drivers/net/ethernet/3com/3c589_cs.c                     |    7 ++----=
-
 drivers/net/ethernet/agere/et131x.c                      |    6 ++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         |    2 ++
 drivers/net/ethernet/broadcom/b44.c                      |    2 +-
 drivers/net/ethernet/broadcom/bgmac.c                    |    7 ++++--=
-
 drivers/net/ethernet/broadcom/tg3.c                      |    2 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c           |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |   11 ++++++=
++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c           |   34 ++++++=
+++++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |   19 ++++++=
++++++-------
 drivers/net/ethernet/sun/sunvnet.c                       |   23 ++++++=
++++-------------
 drivers/net/ipvlan/ipvlan.h                              |    2 +-
 drivers/net/phy/micrel.c                                 |   28 ++++++=
++++++++++++++++++++++
 drivers/net/usb/hso.c                                    |    2 +-
 drivers/net/usb/r8152.c                                  |   59 ++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/vxlan.c                                      |   38 ++++++=
+++++++++++++++++++-------------
 drivers/net/wireless/b43/main.c                          |    4 ++--
 drivers/net/wireless/b43legacy/main.c                    |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c    |    2 +-
 drivers/net/wireless/rtlwifi/pci.c                       |    5 +----
 drivers/spi/spi-bcm53xx.c                                |    2 +-
 drivers/ssb/driver_gige.c                                |    2 +-
 drivers/usb/host/bcma-hcd.c                              |    2 +-
 drivers/usb/host/ssb-hcd.c                               |    2 +-
 drivers/vhost/net.c                                      |   11 ++++++=
-----
 include/linux/mod_devicetable.h                          |    4 ----
 include/linux/netdevice.h                                |   62 ++++++=
++++++++++++++++++++++++++++++++++++++++++++++----------
 include/linux/skbuff.h                                   |   32 ++++++=
++++++++++++++++++++------
 include/net/checksum.h                                   |    5 +++++
 include/net/vxlan.h                                      |    4 +++-
 include/uapi/linux/fou.h                                 |    1 +
 include/uapi/linux/if_link.h                             |    1 +
 net/bridge/br_netfilter.c                                |    7 ++----=
-
 net/core/dev.c                                           |    3 ++-
 net/core/filter.c                                        |    2 +-
 net/core/pktgen.c                                        |    2 +-
 net/core/rtnetlink.c                                     |    9 ++++++=
++-
 net/dsa/slave.c                                          |    9 ++++++=
+--
 net/ipv4/devinet.c                                       |    2 +-
 net/ipv4/fou.c                                           |   42 ++++++=
+++++++++++++++++++++++-------------
 net/ipv4/tcp_fastopen.c                                  |   32 ++++++=
++++++++++++++++++--------
 net/ipv4/udp_offload.c                                   |   13 ++++++=
++++++-
 net/ipv6/ip6_flowlabel.c                                 |    4 ++--
 net/ipv6/ip6_output.c                                    |    2 +-
 net/ipv6/route.c                                         |    2 +-
 net/ipv6/udp_offload.c                                   |    6 +++++-
 net/netfilter/nft_compat.c                               |   63 ++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++------
 net/netfilter/nft_lookup.c                               |    1 +
 net/openvswitch/flow.c                                   |    2 ++
 net/openvswitch/flow_netlink.c                           |    4 ++--
 net/rds/cong.c                                           |   16 ++++++=
+++++++++-
 52 files changed, 483 insertions(+), 143 deletions(-)
