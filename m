From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 23 Aug 2008 05:24:03 -0700 (PDT)
Message-ID: <20080823.052403.235513545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36730
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752764AbYHWMYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 08:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are some bug fixes:

1) Zebra routing daemon is confused because ipv6 netlink
   event messages don't set the protocol field properly
   like ipv4 ones do.  Fix from Stephen Hemminger.

2) Insufficient qdisc list locking leads to Qdisc corruption
   and oops.  Fix from Jarek Poplawski.

3) Qdisc watchdog timer can race with dev_deactivate(), put
   state tests in the slow path to prevent this.  Also from
   Jarek Poplawski.

4) Several SCTP-AUTH sock options are user OOPS'able.  Fix from Vlad
   Yasevich.

5) Fix smp_processor_id() usage by icmp_sk(), needs to disable
   preemption.  Fix from Denis V. Lunev

Please pull, thanks a lot.

The following changes since commit 6a55617ed5d1aa62b850de2cf66f5ede2eef4825:
  Linus Torvalds (1):
        Linux v2.6.27-rc4

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Denis V. Lunev (1):
      icmp: icmp_sk() should not use smp_processor_id() in preemptible code

Jarek Poplawski (2):
      pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
      pkt_sched: Fix qdisc list locking

Stephen Hemminger (1):
      ipv6: protocol for address routes

Vlad Yasevich (1):
      sctp: fix potential panics in the SCTP-AUTH API.

 include/net/pkt_sched.h   |    1 +
 include/net/sch_generic.h |    5 +++
 net/ipv4/icmp.c           |   22 +++++++----
 net/ipv6/addrconf.c       |    1 +
 net/ipv6/icmp.c           |   23 ++++++------
 net/sched/sch_api.c       |   48 +++++++++++++++++++++++---
 net/sched/sch_cbq.c       |    4 ++
 net/sched/sch_generic.c   |    5 +--
 net/sctp/endpointola.c    |    4 +-
 net/sctp/socket.c         |   85 ++++++++++++++++++++++++++++++++++----------
 10 files changed, 149 insertions(+), 49 deletions(-)
