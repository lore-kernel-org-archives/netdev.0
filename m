From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 02 Nov 2017 00:03:41 +0900 (KST)
Message-ID: <20171102.000341.1829980122636333553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix refcounting in xfrm_bundle_lookup() when using a dummy bundle,
   from Steffen Klassert.

2) Fix crypto header handling in rx data frames in ath10k driver,
   from Vasanthakumar Thiagarajan.

3) Fix use after free of qdisc when we defer tcp_chain_flush() to
   a workqueue.  From Cong Wang.

4) Fix double free in lapbether driver, from Pan Bian.

5) Sanitize TUNSETSNDBUF values, from Craig Gallek.

6) Fix refcounting when addrconf_permanent_addr() calls
   ipv6_del_addr().  From Eric Dumazet.

7) Fix MTU probing bug in TCP that goes back to 2007, from
   Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 0b07194bb55ed836c2cc7c22e866b87a14681984:

  Linux 4.14-rc7 (2017-10-29 13:58:38 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 2b7cda9c35d3b940eb9ce74b30bbd5eb30db493d:

  tcp: fix tcp_mtu_probe() vs highest_sack (2017-11-01 21:18:34 +0900)

----------------------------------------------------------------
Andrew Lunn (1):
      net: phy: marvell: Only configure RGMII delays when using RGMII

Brenda J. Butler (1):
      tc-testing: fix arg to ip command: -s -> -n

Cong Wang (1):
      net_sched: remove tcf_block_put_deferred()

Craig Gallek (1):
      tun/tap: sanitize TUNSETSNDBUF input

David S. Miller (2):
      Merge tag 'wireless-drivers-for-davem-2017-10-31' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec

Eric Dumazet (2):
      ipv6: addrconf: increment ifp refcount before ipv6_del_addr()
      tcp: fix tcp_mtu_probe() vs highest_sack

Guillaume Nault (1):
      l2tp: hold tunnel in pppol2tp_connect()

Ido Schimmel (1):
      mlxsw: reg: Add high and low temperature thresholds

Jia-Ju Bai (1):
      wcn36xx: Remove unnecessary rcu_read_unlock in wcn36xx_bss_info_changed

John Fastabend (1):
      bpf: remove SK_REDIRECT from UAPI

Jonathan Basseri (1):
      xfrm: Clear sk_dst_cache when applying per-socket policy.

Kalle Valo (2):
      Revert "ath10k: fix napi_poll budget overflow"
      Merge ath-current from ath.git

Pan Bian (2):
      net: lapbether: fix double free
      net: hns: set correct return value

Steffen Klassert (2):
      xfrm: Fix xfrm_dst_cache memleak
      xfrm: Fix GSO for IPsec with GRE tunnel.

Vadim Pasternak (1):
      mlxsw: i2c: Fix buffer increment counter for write transaction

Vasanthakumar Thiagarajan (1):
      ath10k: rebuild crypto header in rx data frames

Yotam Gigi (1):
      MAINTAINERS: Update Yotam's E-mail

Yuval Mintz (1):
      MAINTAINERS: Remove Yotam from mlxfw

 MAINTAINERS                                   |   6 ++--
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   4 +--
 drivers/net/ethernet/mellanox/mlxsw/i2c.c     |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h     |  25 ++++++++++++++
 drivers/net/phy/marvell.c                     |   8 +++--
 drivers/net/tap.c                             |   2 ++
 drivers/net/tun.c                             |   4 +++
 drivers/net/wan/lapbether.c                   |   1 -
 drivers/net/wireless/ath/ath10k/htt_rx.c      | 122 +++++++++++++++++++++++++++++++++++++++++++++++++++++----------------
 drivers/net/wireless/ath/ath10k/rx_desc.h     |   3 ++
 drivers/net/wireless/ath/wcn36xx/main.c       |   1 -
 include/net/tcp.h                             |   6 ++--
 include/uapi/linux/bpf.h                      |   1 -
 kernel/bpf/sockmap.c                          |  16 ++++++---
 net/ife/ife.c                                 |   2 +-
 net/ipv4/tcp_output.c                         |   3 +-
 net/ipv6/addrconf.c                           |   1 +
 net/l2tp/l2tp_ppp.c                           |   7 +++-
 net/psample/psample.c                         |   2 +-
 net/sched/act_sample.c                        |   2 +-
 net/sched/cls_api.c                           |  37 +++++----------------
 net/xfrm/xfrm_output.c                        |   4 ++-
 net/xfrm/xfrm_policy.c                        |   1 -
 net/xfrm/xfrm_state.c                         |   1 +
 tools/include/uapi/linux/bpf.h                |   3 +-
 tools/testing/selftests/tc-testing/tdc.py     |   4 +--
 26 files changed, 182 insertions(+), 86 deletions(-)
