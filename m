From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 00/47] vlan cleanup
Date: Wed, 20 Jul 2011 16:54:02 +0200
Message-ID: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47076 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317Ab1GTOy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:54:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset converts several drivers to new vlan model.
Also kills several vlan helpers:
lro_vlan_hwaccel_receive_skb
lro_vlan_hwaccel_receive_frags
__vlan_hwaccel_rx
vlan_hwaccel_rx
vlan_hwaccel_receive_skb
vlan_gro_frags
vlan_gro_receive

Removes ndo_vlan_rx_register

note gianfar patch is dependent on "[PATCH] gianfar: rx parser"

Jiri Pirko (47):
  gianfar: rx parser
  vlan: finish removing vlan_find_dev from public header
  vlan: introduce __vlan_find_dev_deep()
  nes: do vlan cleanup
  ehea: do vlan cleanup
  lro: kill lro_vlan_hwaccel_receive_skb
  lro: kill lro_vlan_hwaccel_receive_frags
  lro: do vlan cleanup
  amd8111e: do vlan cleanup
  atl1c: do vlan cleanup
  atl1e: do vlan cleanup
  bnad: do vlan cleanup
  chelsio: do vlan cleanup
  cxgb4vf: do vlan cleanup
  cxgb4: remove forgotten unused vlan_group
  enic: do vlan cleanup
  gianfar: do vlan cleanup
  igbvf: do vlan cleanup
  jme: do vlan cleanup
  mlx4: do vlan cleanup
  qlge: do vlan cleanup
  s2io: do vlan cleanup
  spider_net: do not mention dying vlan_hwaccel_receive_skb
  tehuti: do vlan cleanup
  vlan: kill vlan_hwaccel_receive_skb
  ixgbevf: do vlan cleanup
  acenic: do vlan cleanup
  via-velocity: do vlan cleanup
  starfire: do vlan cleanup
  ns83820: do vlan cleanup
  atl1: do vlan cleanup
  atl2: do vlan cleanup
  cxgb3: do vlan cleanup
  vlan: kill __vlan_hwaccel_rx and vlan_hwaccel_rx
  e1000: do vlan cleanup
  forcedeth: do vlan cleanup
  igb: do vlan cleanup
  vxge: do vlan cleanup
  qeth: do vlan cleanup
  vlan: kill vlan_gro_frags and vlan_gro_receive
  stmmac: do vlan cleanup
  qlcnic: remove usage of vlan_group_get_device
  staging: et131x: remove unused prototype et131x_vlan_rx_register
  bonding: do vlan cleanup
  macvlan: do vlan cleanup
  vlan: kill ndo_vlan_rx_register
  vlan: move vlan_group_[gs]et_device to public header

 drivers/infiniband/hw/nes/nes_hw.c     |   19 ++---
 drivers/infiniband/hw/nes/nes_hw.h     |    4 -
 drivers/infiniband/hw/nes/nes_nic.c    |   50 ++++++++---
 drivers/net/acenic.c                   |   60 ++----------
 drivers/net/acenic.h                   |    7 --
 drivers/net/amd8111e.c                 |   34 +------
 drivers/net/amd8111e.h                 |    3 -
 drivers/net/atl1c/atl1c.h              |    1 -
 drivers/net/atl1c/atl1c_main.c         |   74 +++++++++------
 drivers/net/atl1e/atl1e.h              |    1 -
 drivers/net/atl1e/atl1e_main.c         |   79 ++++++++++------
 drivers/net/atlx/atl1.c                |   21 ++--
 drivers/net/atlx/atl1.h                |    1 -
 drivers/net/atlx/atl2.c                |   78 +++++++++------
 drivers/net/atlx/atl2.h                |    3 -
 drivers/net/atlx/atlx.c                |   57 ++++++++----
 drivers/net/bna/bnad.c                 |   55 ++++--------
 drivers/net/bna/bnad.h                 |    3 +-
 drivers/net/bonding/bond_alb.c         |    4 +-
 drivers/net/bonding/bond_ipv6.c        |    8 +-
 drivers/net/bonding/bond_main.c        |   98 ++++---------------
 drivers/net/bonding/bonding.h          |    6 +-
 drivers/net/chelsio/common.h           |    2 -
 drivers/net/chelsio/cxgb2.c            |   39 +++++---
 drivers/net/chelsio/sge.c              |   18 ++--
 drivers/net/chelsio/sge.h              |    2 +-
 drivers/net/cxgb3/adapter.h            |    2 -
 drivers/net/cxgb3/cxgb3_main.c         |   51 ++++++++--
 drivers/net/cxgb3/cxgb3_offload.c      |    9 +-
 drivers/net/cxgb3/sge.c                |   35 +------
 drivers/net/cxgb4/cxgb4.h              |    1 -
 drivers/net/cxgb4vf/adapter.h          |    1 -
 drivers/net/cxgb4vf/cxgb4vf_main.c     |   50 +++++++----
 drivers/net/cxgb4vf/sge.c              |   34 ++-----
 drivers/net/e1000/e1000.h              |    2 +-
 drivers/net/e1000/e1000_main.c         |  101 +++++++++++---------
 drivers/net/ehea/ehea.h                |    1 -
 drivers/net/ehea/ehea_main.c           |   54 ++---------
 drivers/net/enic/enic.h                |    1 -
 drivers/net/enic/enic_main.c           |   32 +-----
 drivers/net/forcedeth.c                |   68 ++++++--------
 drivers/net/gianfar.c                  |   77 +++++++++------
 drivers/net/gianfar.h                  |    6 +-
 drivers/net/gianfar_ethtool.c          |    3 +
 drivers/net/igb/igb.h                  |    4 +-
 drivers/net/igb/igb_main.c             |   79 ++++++++--------
 drivers/net/igbvf/igbvf.h              |    4 +-
 drivers/net/igbvf/netdev.c             |   51 +++++------
 drivers/net/ixgbevf/ixgbevf.h          |    6 +-
 drivers/net/ixgbevf/ixgbevf_main.c     |   63 +++++-------
 drivers/net/jme.c                      |   28 +-----
 drivers/net/jme.h                      |    4 -
 drivers/net/macvlan.c                  |   12 ---
 drivers/net/mlx4/en_netdev.c           |   49 ++--------
 drivers/net/mlx4/en_port.c             |   23 ++---
 drivers/net/mlx4/en_rx.c               |   24 +++--
 drivers/net/mlx4/mlx4_en.h             |    6 +-
 drivers/net/ns83820.c                  |   33 +------
 drivers/net/qlcnic/qlcnic_main.c       |    7 +-
 drivers/net/qlge/qlge.h                |    3 +-
 drivers/net/qlge/qlge_main.c           |  164 +++++++++++++++++---------------
 drivers/net/s2io.c                     |   70 +------------
 drivers/net/s2io.h                     |    1 -
 drivers/net/spider_net.c               |    4 +-
 drivers/net/starfire.c                 |   89 ++++++++----------
 drivers/net/stmmac/stmmac.h            |    3 -
 drivers/net/stmmac/stmmac_main.c       |   17 ----
 drivers/net/tehuti.c                   |   37 ++------
 drivers/net/tehuti.h                   |    1 -
 drivers/net/via-velocity.c             |   49 ++++------
 drivers/net/via-velocity.h             |    2 +-
 drivers/net/vxge/vxge-main.c           |   91 +++---------------
 drivers/net/vxge/vxge-main.h           |    5 +-
 drivers/s390/net/qeth_core.h           |    2 +-
 drivers/s390/net/qeth_core_main.c      |    1 -
 drivers/s390/net/qeth_l3_main.c        |  100 +++++++++-----------
 drivers/staging/et131x/et131x_netdev.c |    1 -
 include/linux/if_vlan.h                |   80 +---------------
 include/linux/inet_lro.h               |   19 ----
 include/linux/netdevice.h              |    8 --
 net/8021q/vlan.c                       |    4 -
 net/8021q/vlan.h                       |   19 ++++
 net/8021q/vlan_core.c                  |   46 ++++-----
 net/ipv4/inet_lro.c                    |   74 ++------------
 84 files changed, 1004 insertions(+), 1534 deletions(-)

-- 
1.7.6

