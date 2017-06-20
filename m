From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 20 Jun 2017 16:05:07 -0400 (EDT)
Message-ID: <20170620.160507.1165043334851767117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix refcounting wrt. timers which hold onto inet6 address objects,
   from Xin Long.

2) Fix an ancient bug in wireless wext ioctls, from Johannes Berg.

3) Firmware handling fixes in brcm80211 driver, from Arend Van Spriel.

4) Several mlx5 driver fixes (firmware readiness, timestamp cap reporting,
   devlink command validity checking, tc offloading, etc.)  From Eli
   Cohen, Maor Dickman, Chris Mi, and Or Gerlitz.

5) Fix dst leak in IP/IP6 tunnels, from Haishuang Yan.

6) Fix dst refcount bug in decnet, from Wei Wang.

7) Netdev can be double freed in register_vlan_device().  Fix from
   Gao Feng.

8) Don't allow object to be destroyed while it is being dumped in
   SCTP, from Xin Long.

9) Fix dpaa_eth build when modular, from Madalin Bucur.

10) Fix throw route leaks, from Serhey Popovych.

11) IFLA_GROUP missing from if_nlmsg_size() and ifla_policy[] table,
    also from Serhey Popovych.

12) Fix premature TX SKB free in stmmac, from Niklas Cassel.

Please pull, thanks a lot!

The following changes since commit a090bd4ff8387c409732a8e059fbf264ea0bdd56:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-06-15 18:09:47 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to b4846fc3c8559649277e3e4e6b5cec5348a8d208:

  igmp: add a missing spin_lock_init() (2017-06-20 15:51:57 -0400)

----------------------------------------------------------------
Arend Van Spriel (5):
      brcmfmac: add parameter to pass error code in firmware callback
      brcmfmac: use firmware callback upon failure to load
      brcmfmac: unbind all devices upon failure in firmware callback
      brcmfmac: fix brcmf_fws_add_interface() for USB devices
      brcmfmac: fix uninitialized warning in brcmf_usb_probe_phase2()

Chris Mi (1):
      net/mlx5e: Fix min inline value for VF rep SQs

David Howells (1):
      rxrpc: Fix several cases where a padded len isn't checked in ticket decode

David S. Miller (4):
      Merge tag 'mlx5-fixes-2017-06-14' of git://git.kernel.org/.../saeed/linux
      Merge tag 'mac80211-for-davem-2017-06-16' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'net-fix-loadable-module-for-DPAA-Ethernet'
      Merge tag 'wireless-drivers-for-davem-2017-06-20' of git://git.kernel.org/.../kvalo/wireless-drivers

Edward Cree (1):
      sfc: remove duplicate up_write on VF filter_sem

Eli Cohen (1):
      net/mlx5: Wait for FW readiness before initializing command interface

Gao Feng (1):
      net: 8021q: Fix one possible panic caused by BUG_ON in free_netdev

Haishuang Yan (3):
      ip_tunnel: fix potential issue in ip_tunnel_rcv
      ip6_tunnel: fix potential issue in __ip6_tnl_rcv
      ip6_tunnel: Correct tos value in collect_md mode

Johannes Berg (3):
      wireless: wext: remove ndo_do_ioctl fallback
      wireless: wext: use struct iwreq earlier in the call chain
      dev_ioctl: copy only the smaller struct iwreq for wext

Krzysztof Kozlowski (1):
      dt-bindings: net: sms911x: Add missing optional VDD regulators

Lin Yun Sheng (1):
      net/hns:bugfix of ethtool -t phy self_test

Madalin Bucur (2):
      fsl/fman: propagate dma_ops
      dpaa_eth: reuse the dma_ops provided by the FMan MAC device

Maor Dickman (1):
      net/mlx5e: Fix timestamping capabilities reporting

Niklas Cassel (1):
      net: stmmac: free an skb first when there are no longer any descriptors using it

Or Gerlitz (3):
      net/mlx5: Properly check applicability of devlink eswitch commands
      net/mlx5e: Remove TC header re-write offloading of ip tos
      net/mlx5e: Avoid doing a cleanup call if the profile doesn't have it

Raju Rangoju (1):
      cxgb4: notify uP to route ctrlq compl to rdma rspq

Sebastian Siewior (1):
      net/core: remove explicit do_softirq() from busy_poll_stop()

Serhey Popovych (3):
      fib_rules: Resolve goto rules target on delete
      ipv6: Do not leak throw route references
      rtnetlink: add IFLA_GROUP to ifla_policy

WANG Cong (1):
      igmp: add a missing spin_lock_init()

Wei Wang (1):
      decnet: always not take dst->__refcnt when inserting dst into hash table

Xin Long (3):
      ipv6: fix calling in6_ifa_hold incorrectly for dad work
      sctp: return next obj by passing pos + 1 into sctp_transport_get_idx
      sctp: ensure ep is not destroyed before doing the dump

xypron.glpk@gmx.de (1):
      Doc: net: dsa: b53: update location of referenced dsa.txt

 Documentation/devicetree/bindings/net/dsa/b53.txt           |  2 +-
 Documentation/devicetree/bindings/net/smsc911x.txt          |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c             | 10 ++++++----
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c              |  2 +-
 drivers/net/ethernet/freescale/fman/mac.c                   |  2 ++
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c            | 16 ++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c        |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c           |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c            |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c             |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c  | 77 ++++++++++++++++++++++++++++++++++++++++-------------------------------------
 drivers/net/ethernet/mellanox/mlx5/core/main.c              | 14 ++++++++++++--
 drivers/net/ethernet/sfc/ef10_sriov.c                       |  2 --
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c           | 20 ++++++++++++++++----
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c | 35 +++++++++++++++++------------------
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h |  4 ++--
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c |  2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.c     | 17 ++++++++++++-----
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c     | 18 ++++++++++++------
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c      |  9 +++++----
 include/net/wext.h                                          |  4 ++--
 net/8021q/vlan.c                                            |  3 ++-
 net/core/dev.c                                              |  2 --
 net/core/dev_ioctl.c                                        | 19 ++++++++++++++++---
 net/core/fib_rules.c                                        | 21 ++++++++++++++-------
 net/core/rtnetlink.c                                        |  2 ++
 net/decnet/dn_route.c                                       | 14 ++++----------
 net/ipv4/igmp.c                                             |  1 +
 net/ipv4/ip_tunnel.c                                        |  2 ++
 net/ipv6/addrconf.c                                         |  6 +++---
 net/ipv6/fib6_rules.c                                       | 22 ++++++----------------
 net/ipv6/ip6_fib.c                                          |  3 +--
 net/ipv6/ip6_tunnel.c                                       |  6 ++++--
 net/rxrpc/key.c                                             | 64 ++++++++++++++++++++++++++++++++++------------------------------
 net/sctp/endpointola.c                                      |  1 +
 net/sctp/sctp_diag.c                                        |  5 +++--
 net/sctp/socket.c                                           |  5 ++---
 net/wireless/wext-core.c                                    | 22 +++++++++-------------
 38 files changed, 256 insertions(+), 191 deletions(-)
