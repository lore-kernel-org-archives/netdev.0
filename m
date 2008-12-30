From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 30 Dec 2008 00:01:08 -0800 (PST)
Message-ID: <20081230.000108.48849250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53734
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750941AbYL3IBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 03:01:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix more build warning and failure fallout from the NAPI
   device arg drop.

2) A counter deadlock was introduced by some percpu counter
   changes for networking we made.  Thanks to Ingo Molnar,
   Peter Z., and Herbert Xu these should be cured now.

3) Lots of small changes and fixes to a few drivers.

4) Fix an OOPS in the control group packet classifier, plus
   some small cleanups.  From Li Zefan.

5) Network namespace shutdown crash fix from Eric W. Biederman.

Please pull, thanks a lot!

The following changes since commit 3c92ec8ae91ecf59d88c798301833d7cf83f2179:
  Linus Torvalds (1):
        Merge branch 'next' of git://git.kernel.org/.../paulus/powerpc

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (1):
      smsc911x: compile fix re netif_rx signature changes

David S. Miller (1):
      net: Fix unused variable warnings in pasemi_mac.c and spider_net.c

Eric W. Biederman (1):
      netns: foreach_netdev_safe is insufficient in default_device_exit

Herbert Xu (1):
      net: Fix percpu counters deadlock

Huang Weiyi (1):
      net: KS8695: removed duplicated #include

Julia Lawall (1):
      drivers/net/usb: use USB API functions rather than constants

Kamalesh Babulal (1):
      net: Fix more NAPI interface netdev argument drop fallout.

Kusanagi Kouichi (1):
      tun: Fix SIOCSIFHWADDR error.

Li Zefan (3):
      cls_cgroup: fix an oops when removing a cgroup
      cls_cgroup: clean up for cgroup part
      cls_cgroup: clean up Kconfig

Roel Kluin (1):
      EtherExpress16: fix printing timed out status

Rusty Russell (2):
      net: make xfrm_statistics_seq_show use generic snmp_fold_field
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_bits: net

Simon Horman (1):
      IPVS: Make "no destination available" message more consistent between schedulers

Yevgeny Petrilin (3):
      mlx4_en: Verify number of RX rings doesn't exceed MAX_RX_RINGS
      mlx4_en: Always allocate RX ring for each interrupt vector
      mlx4_en: Added "set_ringparam" Ethtool interface implementation

 drivers/net/arm/ep93xx_eth.c                       |    2 +-
 drivers/net/arm/ixp4xx_eth.c                       |    2 +-
 drivers/net/arm/ks8695net.c                        |    1 -
 drivers/net/eexpress.h                             |   56 ++++++------
 drivers/net/mlx4/en_main.c                         |   11 +--
 drivers/net/mlx4/en_netdev.c                       |    8 +-
 drivers/net/mlx4/en_params.c                       |   87 ++++++++++++--------
 drivers/net/mlx4/mlx4_en.h                         |    6 ++
 drivers/net/pasemi_mac.c                           |    2 -
 drivers/net/smsc911x.c                             |    4 +-
 drivers/net/spider_net.c                           |    1 -
 drivers/net/tun.c                                  |    2 +-
 drivers/net/usb/hso.c                              |    2 +-
 drivers/net/wan/ixp4xx_hss.c                       |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |    3 +-
 net/core/dev.c                                     |    8 +-
 net/core/neighbour.c                               |    4 +-
 net/dccp/proto.c                                   |    3 +-
 net/ipv4/inet_connection_sock.c                    |    4 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    4 +-
 net/ipv4/proc.c                                    |   13 ++-
 net/ipv4/route.c                                   |    4 +-
 net/ipv4/tcp.c                                     |    3 +-
 net/ipv4/tcp_ipv4.c                                |    3 +
 net/ipv6/tcp_ipv6.c                                |    3 +
 net/netfilter/ipvs/ip_vs_lblc.c                    |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c                   |    2 +-
 net/netfilter/ipvs/ip_vs_lc.c                      |   14 ++-
 net/netfilter/ipvs/ip_vs_nq.c                      |    4 +-
 net/netfilter/ipvs/ip_vs_rr.c                      |    1 +
 net/netfilter/ipvs/ip_vs_sed.c                     |    1 +
 net/netfilter/ipvs/ip_vs_sh.c                      |    1 +
 net/netfilter/ipvs/ip_vs_wlc.c                     |    1 +
 net/netfilter/ipvs/ip_vs_wrr.c                     |    8 ++-
 net/netfilter/nf_conntrack_standalone.c            |    4 +-
 net/sched/Kconfig                                  |    3 -
 net/sched/cls_cgroup.c                             |   23 +++--
 net/xfrm/xfrm_proc.c                               |   17 +----
 38 files changed, 176 insertions(+), 143 deletions(-)
