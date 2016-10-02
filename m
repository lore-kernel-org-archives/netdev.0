From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 02 Oct 2016 09:01:57 -0400 (EDT)
Message-ID: <20161002.090157.261210264494797792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751006AbcJBNCL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2016 09:02:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix wrong TCP checksums on MTU probing when checksum offloading is
   disabled, from Douglas Caetano dos Santos.

2) Fix qdisc backlog updates in qfq and sfb schedulers, from Cong Wang.

3) Route lookup flow key protocol value is wrong in ip6gre_xmit_other(),
   fix from Lance Richardson.

4) Scheduling while atomic in multicast routing code of ipv4 and ipv6,
   fix from Nikolay Aleksandrov.

5) Fix packet alignment in fec driver, from Eric Nelson.

6) Fix perf regression in sctp due to struct layout and cache misses,
   from Xin Long.

Please pull, thanks a lot!

The following changes since commit b1f2beb87bb034bb209773807994279f90cace78:

  Merge tag 'media/v4.8-7' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media (2016-09-22 09:04:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 1cceda7849809a8857fd9f26efe8846506c710e1:

  sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock (2016-09-30 02:08:57 -0400)

----------------------------------------------------------------
David S. Miller (4):
      Merge tag 'linux-can-fixes-for-4.8-20160922' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'fec-align'
      Merge branch 'act_ife-fixes'
      Merge branch 'sctp-fixes'

Douglas Caetano dos Santos (1):
      tcp: fix wrong checksum calculation on MTU probing

Eric Dumazet (1):
      tcp: fix a compile error in DBGUNDO()

Eric Nelson (3):
      net: fec: remove QUIRK_HAS_RACC from i.mx25
      net: fec: remove QUIRK_HAS_RACC from i.mx27
      net: fec: align IP header in hardware

Florian Fainelli (1):
      Revert "net: ethernet: bcmgenet: use phydev from struct net_device"

Jorgen Hansen (1):
      VSOCK: Don't dec ack backlog twice for rejected connections

Lance Richardson (1):
      ip6_gre: fix flowi6_proto value in ip6gre_xmit_other()

Milton Miller (1):
      tg3: Avoid NULL pointer dereference in tg3_io_error_detected()

Nikolay Aleksandrov (1):
      ipmr, ip6mr: fix scheduling while atomic and a deadlock with ipmr_get_route

Sergei Miroshnichenko (1):
      can: dev: fix deadlock reported after bus-off

WANG Cong (2):
      sch_qfq: keep backlog updated with qlen
      sch_sfb: keep backlog updated with qlen

Xin Long (4):
      sctp: move sent_count to the memory hole in sctp_chunk
      sctp: remove prsctp_param from sctp_chunk
      sctp: change to check peer prsctp_capable when using prsctp polices
      sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock

Yotam Gigi (2):
      act_ife: Fix external mac header on encode
      act_ife: Fix false encoding

 drivers/net/can/dev.c                          | 27 +++++++++++++++++----------
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 45 +++++++++++++++++++++++++--------------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 24 +++++++++++++-----------
 drivers/net/ethernet/broadcom/tg3.c            | 10 +++++-----
 drivers/net/ethernet/freescale/fec_main.c      | 15 ++++++++++++---
 include/linux/can/dev.h                        |  3 ++-
 include/linux/mroute.h                         |  2 +-
 include/linux/mroute6.h                        |  2 +-
 include/net/sctp/structs.h                     | 13 +++----------
 net/ipv4/ipmr.c                                |  3 ++-
 net/ipv4/route.c                               |  3 ++-
 net/ipv4/tcp_input.c                           |  3 +--
 net/ipv4/tcp_output.c                          | 12 +++++++-----
 net/ipv6/ip6_gre.c                             |  1 -
 net/ipv6/ip6mr.c                               |  5 +++--
 net/ipv6/route.c                               |  4 +++-
 net/sched/act_ife.c                            |  7 +++----
 net/sched/sch_qfq.c                            |  3 +++
 net/sched/sch_sfb.c                            |  3 +++
 net/sctp/chunk.c                               | 11 ++++++++---
 net/sctp/outqueue.c                            | 12 ++++++------
 net/sctp/sctp_diag.c                           | 58 ++++++++++++++++++++++++++++++++++++++++------------------
 net/sctp/sm_make_chunk.c                       | 15 ---------------
 net/sctp/socket.c                              | 10 +++++++---
 net/vmw_vsock/af_vsock.c                       |  6 +++---
 26 files changed, 171 insertions(+), 127 deletions(-)
