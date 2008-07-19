From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v2 0/3] Add size table feature for qdiscs
Date: Sun, 20 Jul 2008 02:34:55 +0300
Message-ID: <20080719233441.12596.91242.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:54101 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbYGSXe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 19:34:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds generic size table for qdiscs that is similiar to rate table
used by htb/tbf/cbq.

Changes since v1:
 - ingress qdisc / actions handled too
 - size of table is now dynamic
 - add qdisc_enqueue_root wrapper

---

Jussi Kivilinna (3):
      net_sched: Add size table for qdiscs
      net_sched: Add accessor function for packet length for qdiscs
      net_sched: Add qdisc_enqueue wrapper


 include/linux/pkt_sched.h |   20 ++++++
 include/linux/rtnetlink.h |    1 
 include/net/pkt_sched.h   |    1 
 include/net/sch_generic.h |   50 +++++++++++++--
 net/core/dev.c            |    4 +
 net/mac80211/wme.c        |    2 -
 net/sched/act_gact.c      |    2 -
 net/sched/act_ipt.c       |    2 -
 net/sched/act_mirred.c    |    4 +
 net/sched/act_nat.c       |    2 -
 net/sched/act_pedit.c     |    2 -
 net/sched/act_police.c    |    8 +-
 net/sched/act_simple.c    |    2 -
 net/sched/sch_api.c       |  151 ++++++++++++++++++++++++++++++++++++++++++++-
 net/sched/sch_atm.c       |    6 +-
 net/sched/sch_cbq.c       |   19 +++---
 net/sched/sch_dsmark.c    |    4 +
 net/sched/sch_fifo.c      |    2 -
 net/sched/sch_generic.c   |    1 
 net/sched/sch_gred.c      |   12 ++--
 net/sched/sch_hfsc.c      |   16 ++---
 net/sched/sch_htb.c       |   12 ++--
 net/sched/sch_ingress.c   |    2 -
 net/sched/sch_netem.c     |   27 +++++---
 net/sched/sch_prio.c      |    5 +
 net/sched/sch_red.c       |    4 +
 net/sched/sch_sfq.c       |   16 ++---
 net/sched/sch_tbf.c       |    9 +--
 net/sched/sch_teql.c      |    6 +-
 29 files changed, 302 insertions(+), 90 deletions(-)

-- 
