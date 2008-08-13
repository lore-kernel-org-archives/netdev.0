From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 13 Aug 2008 16:45:34 -0700 (PDT)
Message-ID: <20080813.164534.57604323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756023AbYHMXpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 19:45:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We must always be getting better because we're always applying
more and more fixes :-)

1) dev_deactivate probes for quiecence on the wrong qdisc, resulting
   in crashes

2) pktgen can reference invalid TX queues, fix from Andrew Gallatin

3) IGMP net namespace crash fix from Daniel Lezcano.

4) BNX2X driver bug fixes from Eilon Greenstein and co.

5) Missing DCCP socket option check from Arnaldo Carvalho de Melo.

6) Fix double-lock deadlock in UDP encapsulation, from Herbert Xu.

7) Packet scheduler TC action fixes from Jamal Hadi Salim.

8) IPVS bug fixes from Simon Horman and Sven Wegener.

9) Route dumping OOPS fix in ipv6 from Brian Haley.

10) TIPC uses internal byte swapping implementation routine, don't
    do that.  From Andrew Morton.

11) CPU utilization when TX queue of device is full is excessive
    due to a thinko in one of the TX multiqueue commits.

12) Ingress filters need to be findable via qdisc_lookup() just like
    egress ones.  Also, filter attachment was referencing the wrong
    qdisc, and therefore not working.  Based upon bug reports by
    Stephen Hemminger.

Please pull, thanks a lot.

The following changes since commit 76aab2c1eae491a5d73ac83deec97dd28ebac584:
  Jamal Hadi Salim (1):
        pkt_sched: Fix actions referencing

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrew Gallatin (1):
      pktgen: prevent pktgen from using bad tx queue

Andrew Morton (1):
      net/tipc/subscr.c: don't use ___constant_swab32

Arnaldo Carvalho de Melo (1):
      dccp: change L/R must have at least one byte in the dccpsf_val field

Brian Haley (1):
      ipv6: Fix OOPS, ip -f inet6 route get fec0::1, linux-2.6.26, ip6_route_output, rt6_fill_node+0x175

Daniel Lezcano (1):
      netns: Fix crash by making igmp per namespace

David S. Miller (4):
      pkt_sched: Fix ingress deletion and filter attachment.
      Merge branch 'stealer/ipvs/for-davem' of git://git.stealer.net/linux-2.6
      pkt_sched: Add queue stopped test back to qdisc_run().
      pkt_sched: Fix queue quiescence testing in dev_deactivate().

Eilon Greenstein (14):
      bnx2x: FW (bootcode) interface fixes
      bnx2x: Not dropping packets with L3/L4 checksum error
      bnx2x: FW Internal Memory structure
      bnx2x: HW attention lock
      bnx2x: Memory allocation
      bnx2x: PBA Table Page Alignment Workaround
      bnx2x: WoL capability
      bnx2x: Change GPIO for any port
      bnx2x: 1G LED does not turn off
      bnx2x: Driver info
      bnx2x: Minor code improvements
      bnx2x: Spelling mistakes
      bnx2x: Checkpatch compliance
      bnx2x: Version update

Gerrit Renker (1):
      skbuff: Code readability NiT

Herbert Xu (1):
      udp: Drop socket lock for encapsulated packets

Jamal Hadi Salim (3):
      wext: Send name on events
      net-sched: Fix actions flushing
      net-sched: fix Action flushing return code

Jarek Poplawski (3):
      pkt_sched: Add BH protection for qdisc_stab_lock.
      pkt_sched: Fix oops in htb_delete.
      pkt_sched: Protect gen estimators under est_lock.

Jean-Christophe DUBOIS (1):
      xfrm: remove unnecessary variable in xfrm_output_resume() 2nd try

Julien Brunel (1):
      net/rxrpc: Use an IS_ERR test rather than a NULL test

Rami Rosen (2):
      ipv6: ip6_route.h cleanup.
      ipv6: Kill unused ip6_prohibit_entry and ip6_blk_hole_entry declarations.

Simon Horman (2):
      ipvs: Explictly clear ip_vs_stats members
      ipvs: add lvs-devel as a list contact

Sven Wegener (9):
      ipvs: Fix possible deadlock in sync code
      ipvs: Fix possible deadlock in estimator code
      ipvs: Use ARRAY_SIZE()
      ipvs: Use list_empty() instead of open-coding the same functionality
      ipvs: Initialize schedulers' struct list_head at compile time
      ipvs: Annotate init functions with __init
      ipvs: Mark net_vs_ctl_path const
      ipvs: Embed estimator object into stats object
      ipvs: No need to zero out ip_vs_stats during initialization

Vladislav Zolotarov (2):
      bnx2x: Load/Unload under traffic
      bnx2x: No LRO without Rx checksum

Yaniv Rosner (3):
      bnx2x: Link order with external PHY
      bnx2x: Pause settings
      bnx2x: 8073 PHY changes

Yitchak Gertner (6):
      bnx2x: Statistics
      bnx2x: HW lock mechanism
      bnx2x: Self-test false positive
      bnx2x: Delay in while loops
      bnx2x: Clearing MAC addresses filters
      bnx2x: Wrong structure size

 MAINTAINERS                     |    1 +
 drivers/net/bnx2x.h             |   87 ++--
 drivers/net/bnx2x_fw_defs.h     |  160 +++---
 drivers/net/bnx2x_hsi.h         |   16 +-
 drivers/net/bnx2x_init.h        |   26 +-
 drivers/net/bnx2x_init_values.h |  533 ++++++++---------
 drivers/net/bnx2x_link.c        | 1258 +++++++++++++++++++++++++--------------
 drivers/net/bnx2x_link.h        |   11 +-
 drivers/net/bnx2x_main.c        | 1212 +++++++++++++++++++++----------------
 drivers/net/bnx2x_reg.h         |  210 ++++---
 include/linux/skbuff.h          |    6 +-
 include/net/ip6_route.h         |    6 -
 include/net/ip_vs.h             |   32 +-
 include/net/pkt_sched.h         |    5 +-
 net/core/gen_estimator.c        |    9 +-
 net/core/pktgen.c               |   29 +
 net/dccp/proto.c                |    5 +
 net/ipv4/igmp.c                 |   71 +--
 net/ipv4/ipvs/ip_vs_app.c       |    2 +-
 net/ipv4/ipvs/ip_vs_conn.c      |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c       |   27 +-
 net/ipv4/ipvs/ip_vs_dh.c        |    2 +-
 net/ipv4/ipvs/ip_vs_est.c       |  116 ++---
 net/ipv4/ipvs/ip_vs_lblc.c      |    2 +-
 net/ipv4/ipvs/ip_vs_lblcr.c     |    2 +-
 net/ipv4/ipvs/ip_vs_lc.c        |    2 +-
 net/ipv4/ipvs/ip_vs_nq.c        |    2 +-
 net/ipv4/ipvs/ip_vs_proto.c     |    4 +-
 net/ipv4/ipvs/ip_vs_rr.c        |    2 +-
 net/ipv4/ipvs/ip_vs_sched.c     |    4 +-
 net/ipv4/ipvs/ip_vs_sed.c       |    2 +-
 net/ipv4/ipvs/ip_vs_sh.c        |    2 +-
 net/ipv4/ipvs/ip_vs_sync.c      |    4 +-
 net/ipv4/ipvs/ip_vs_wlc.c       |    2 +-
 net/ipv4/ipvs/ip_vs_wrr.c       |    2 +-
 net/ipv4/udp.c                  |    6 +-
 net/ipv6/route.c                |    3 +-
 net/ipv6/udp.c                  |    6 +-
 net/rxrpc/ar-accept.c           |    2 +-
 net/sched/act_api.c             |   13 +-
 net/sched/sch_api.c             |   50 +-
 net/sched/sch_generic.c         |   11 +-
 net/sched/sch_htb.c             |    3 +-
 net/tipc/subscr.c               |    2 +-
 net/wireless/wext.c             |    1 +
 net/xfrm/xfrm_output.c          |    5 +-
 46 files changed, 2265 insertions(+), 1693 deletions(-)
