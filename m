From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 00/22] vlan cleanup round1
Date: Fri, 15 Jul 2011 23:33:18 +0200
Message-ID: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394Ab1GOVeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset converts several drivers to new vlan model.
Also kills several vlan helpers:
vlan_hwaccel_receive_skb,
lro_vlan_hwaccel_receive_frags,
lro_vlan_hwaccel_receive_skb

note gianfar patch is dependent on "[PATCH] gianfar: rx parser"

Jiri Pirko (22):
  gianfar: rx parser
  nes: do vlan cleanup
  ehea: unify vlan and nonvlan rx path
  kill lro_vlan_hwaccel_receive_skb
  amd8111e: do vlan cleanup
  atl1c: do vlan cleanup
  atl1e: do vlan cleanup
  bnad: do vlan cleanup
  chelsio: do vlan cleanup
  cxgb4vf: do vlan cleanup
  enic: do vlan cleanup
  gianfar: do vlan cleanup
  igbvf: do vlan cleanup
  jme: do vlan cleanup
  mlx4: do vlan cleanup
  qlge: do vlan cleanup
  s2io: do vlan cleanup
  spider_net: do not mention dying vlan_hwaccel_receive_skb
  tehuti: do vlan cleanup
  lro: unify vlan and nonvlan rx path
  lro: kill lro_vlan_hwaccel_receive_frags
  vlan: kill vlan_hwaccel_receive_skb

 drivers/infiniband/hw/nes/nes_hw.c  |   19 ++---
 drivers/infiniband/hw/nes/nes_hw.h  |    4 -
 drivers/infiniband/hw/nes/nes_nic.c |   42 +++------
 drivers/net/amd8111e.c              |   34 ++------
 drivers/net/amd8111e.h              |    3 -
 drivers/net/atl1c/atl1c.h           |    1 -
 drivers/net/atl1c/atl1c_main.c      |   51 ++----------
 drivers/net/atl1e/atl1e.h           |    1 -
 drivers/net/atl1e/atl1e_main.c      |   49 ++---------
 drivers/net/bna/bnad.c              |   55 ++++--------
 drivers/net/bna/bnad.h              |    3 +-
 drivers/net/chelsio/common.h        |    2 -
 drivers/net/chelsio/cxgb2.c         |   19 +----
 drivers/net/chelsio/sge.c           |   11 +--
 drivers/net/cxgb4vf/adapter.h       |    1 -
 drivers/net/cxgb4vf/cxgb4vf_main.c  |   18 +----
 drivers/net/cxgb4vf/sge.c           |   34 ++------
 drivers/net/ehea/ehea_main.c        |   22 ++---
 drivers/net/enic/enic.h             |    1 -
 drivers/net/enic/enic_main.c        |   32 ++------
 drivers/net/gianfar.c               |   77 ++++++++++-------
 drivers/net/gianfar.h               |    6 +-
 drivers/net/gianfar_ethtool.c       |    3 +
 drivers/net/igbvf/igbvf.h           |    4 +-
 drivers/net/igbvf/netdev.c          |   51 +++++------
 drivers/net/jme.c                   |   28 +-----
 drivers/net/jme.h                   |    4 -
 drivers/net/mlx4/en_netdev.c        |   49 +++--------
 drivers/net/mlx4/en_port.c          |   23 ++---
 drivers/net/mlx4/en_rx.c            |   24 +++---
 drivers/net/mlx4/mlx4_en.h          |    6 +-
 drivers/net/qlge/qlge.h             |    3 +-
 drivers/net/qlge/qlge_main.c        |  164 +++++++++++++++++++----------------
 drivers/net/s2io.c                  |   70 ++--------------
 drivers/net/s2io.h                  |    1 -
 drivers/net/spider_net.c            |    4 +-
 drivers/net/tehuti.c                |   37 ++-------
 drivers/net/tehuti.h                |    1 -
 include/linux/if_vlan.h             |   13 ---
 include/linux/inet_lro.h            |   17 ----
 net/ipv4/inet_lro.c                 |   54 +-----------
 41 files changed, 313 insertions(+), 728 deletions(-)

-- 
1.7.6

