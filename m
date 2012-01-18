From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 18 Jan 2012 00:57:13 -0500 (EST)
Message-ID: <20120118.005713.323927363865759521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This has your brcmsmac fixes as well as:

1) Build regression fix in sh-eth driver from Nobuhiro Iwamatsu.

2) Fix checksum validation in skb_gso_segment() and report the offendin=
g
   context better, from Ben Hutchings and Micha=A9=A9 Miros=A9=A9aw.

3) Revert user-space netfilter expectation helper support, it needs
   some more kinks worked out, from Pablo Neira.

4) Fix idev leak in icmp6_dst_alloc() from RonQing Li.

5) Link handling bug fixes in bnx2x from Yaniv Rosner.

6) Fix wrong device ID for CAIF modems and kill erroneous WARN_ON in
   caif_dev, from Sjur Brandeland.

7) Multpart datapath dumps in openvswitch were truncated, from Ben Pfaf=
f.

8) Per device IP snmp counters in ipv6 regressed, fix from Eric Dumazet=
=2E

Please pull, thanks a lot!

The following changes since commit 6a488979f574cb4287880db2dbc8b13cee30=
c5be:

  Merge tag 'arm-soc-fixes' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/arm/arm-soc (2012-01-17 18:55:56 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Alexandre Oliva (1):
      brcmfmac: work-around gcc 4.7 build issue

Ben Hutchings (2):
      net: Use device model to get driver name in skb_gso_segment()
      net: WARN if skb_checksum_help() is called on skb requiring segme=
ntation

Ben Pfaff (1):
      openvswitch: Fix multipart datapath dumps.

Dan Carpenter (3):
      ipw2x00: signedness bug handling frame length
      mwl8k: fix condition in mwl8k_cmd_encryption_remove_key()
      inetpeer: initialize ->redirect_genid in inet_getpeer()

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss

Devendra Naga (1):
      net: remove version.h includes in net/openvswitch/

Eric Dumazet (3):
      bridge: BH already disabled in br_fdb_cleanup()
      net: fix some sparse errors
      ipv6: fix per device IP snmp counters

=46abio Estevam (1):
      wireless: iwlwifi: iwl-scan.c: Fix build warning

=46elix Fietkau (1):
      ath9k_hw: fix interpretation of the rx KeyMiss flag

Glauber Costa (1):
      net: move sock_update_memcg outside of CONFIG_INET

Guennadi Liakhovetski (1):
      wireless: b43: fix Oops on card eject during transfer

Helmut Schaa (1):
      mac80211: Fix possible race between sta_unblock and network softi=
rq

Hiroaki SHIMODA (1):
      bql: Fix inconsistency between file mode and attr method.

Jesper Juhl (1):
      Net, mac80211: Fix resource leak in ieee80211_rx_h_mesh_fwding()

Johannes Berg (1):
      mac80211: fix no-op authorized transitions

Jozsef Kadlecsik (2):
      netfilter: ipset: autoload set type modules safely
      netfilter: ipset: dumping error triggered removing references twi=
ce

Linus Torvalds (4):
      bcma: convert suspend/resume to pm_ops
      bcma: add stub for bcma_bus_suspend()
      bcma: connect the bcma bus suspend/resume to the bcma driver susp=
end/resume
      brcmsmac: remove PCI suspend/resume from bcma driver

Matt Carlson (1):
      tg3: Fix single-vector MSI-X code

Micha=A9=A9 Miros=A9=A9aw (1):
      net: fix NULL-deref in WARN() in skb_gso_segment()

Nobuhiro Iwamatsu (1):
      net: sh-eth: Fix build error by the value which is not defined

Pablo Neira Ayuso (1):
      netfilter: revert user-space expectation helper support

Rafa=A9=A9 Mi=A9=A9ecki (3):
      MAINTAINERS: move BCMA to keep the list sorted
      MAINTAINERS: add b43 mailing list
      bcma: invalidate the mapped core over suspend/resume

RongQing.Li (1):
      ipv6: release idev when ip6_neigh_lookup failed in icmp6_dst_allo=
c

Shan Wei (1):
      net: kill duplicate included header

Stanislaw Gruszka (1):
      rt2800pci: fix spurious interrupts generation

Stephen Rothwell (1):
      netfilter: xt_hashlimit: fix unused variable warning if IPv6 disa=
bled

Thadeu Lima de Souza Cascardo (1):
      ehea: make some functions and variables static

Yaniv Rosner (5):
      bnx2x: Fix Super-Isolate mode for BCM84833
      bnx2x: Fix PFC setting on BCM57840
      bnx2x: Remove 100Mb force speed for BCM84833
      bnx2x: Remove AutoGrEEEn for BCM84833
      bnx2x: Disable AN KR work-around for BCM57810

Yogesh Ashok Powar (1):
      mwl8k: Fixing Sparse ENDIAN CHECK warning

Yoni Divinsky (1):
      mac80211: fix tx->skb NULL pointer dereference

sjur.brandeland@stericsson.com (2):
      caif: Fix typo in Vendor/Product-ID for CAIF modems
      caif: Remove bad WARN_ON in caif_dev

stephen hemminger (1):
      vhost-net: add module alias (v2.1)

 Documentation/devices.txt                          |    3 +
 MAINTAINERS                                        |   15 +-
 drivers/bcma/bcma_private.h                        |    1 +
 drivers/bcma/host_pci.c                            |   43 ++--
 drivers/bcma/main.c                                |   24 ++
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |  298 +++++++++++-=
--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    1 +
 drivers/net/ethernet/broadcom/tg3.c                |   27 +-
 drivers/net/ethernet/ibm/ehea/ehea_ethtool.c       |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |   32 +-
 drivers/net/ethernet/ibm/ehea/ehea_qmr.c           |   14 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    5 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    5 +-
 drivers/net/wireless/b43/main.c                    |    5 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   40 +---
 drivers/net/wireless/ipw2x00/ipw2200.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    2 +-
 drivers/net/wireless/mwl8k.c                       |    4 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   28 +--
 drivers/vhost/net.c                                |    8 +-
 include/linux/bcma/bcma.h                          |    2 +-
 include/linux/miscdevice.h                         |    1 +
 include/linux/netfilter/nf_conntrack_common.h      |    4 -
 include/linux/netfilter/xt_CT.h                    |    3 +-
 include/net/flow.h                                 |    2 +-
 mm/memcontrol.c                                    |    2 +-
 net/bridge/br_fdb.c                                |    4 +-
 net/caif/caif_dev.c                                |   16 +-
 net/caif/caif_usb.c                                |    3 +-
 net/core/dev.c                                     |   32 ++-
 net/core/net-sysfs.c                               |    2 +-
 net/core/secure_seq.c                              |    2 +-
 net/ipv4/inetpeer.c                                |    3 +-
 net/ipv4/ipconfig.c                                |    8 +-
 net/ipv4/ping.c                                    |   27 +-
 net/ipv4/udp_diag.c                                |    1 -
 net/ipv6/datagram.c                                |    2 +-
 net/ipv6/proc.c                                    |    4 +-
 net/ipv6/route.c                                   |    1 +
 net/mac80211/cfg.c                                 |    2 +-
 net/mac80211/rx.c                                  |    1 +
 net/mac80211/sta_info.c                            |    6 +-
 net/mac80211/tx.c                                  |   10 +-
 net/mac80211/wpa.c                                 |   19 ++
 net/mac80211/wpa.h                                 |    2 +
 net/netfilter/ipset/ip_set_core.c                  |   37 ++-
 net/netfilter/nf_conntrack_helper.c                |   12 -
 net/netfilter/nf_conntrack_netlink.c               |    4 -
 net/netfilter/xt_CT.c                              |    8 +-
 net/netfilter/xt_hashlimit.c                       |    5 +-
 net/openvswitch/datapath.c                         |    8 +-
 net/openvswitch/datapath.h                         |    1 -
 net/openvswitch/flow.c                             |    1 -
 net/openvswitch/vport-internal_dev.c               |    1 -
 net/openvswitch/vport.c                            |    1 -
 58 files changed, 429 insertions(+), 380 deletions(-)
