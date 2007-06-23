From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: Multiple queue hardware support
Date: Sat, 23 Jun 2007 14:36:14 -0700
Message-ID: <20070623213614.18241.45511.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10021 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751851AbXFWVgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 17:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please consider these patches for 2.6.23 inclusion.

These patches are built against Patrick McHardy's recently submitted
RTNETLINK nested compat attribute patches.  They're needed to preserve
ABI between sch_{rr|prio} and iproute2.

Updates since the last submission:

1. Added checks for netif_subqueue_stopped() to net/core/netpoll.c,
   net/core/pktgen.c, and to software device hard_start_xmit in
   dev_queue_xmit().

2. Removed TCA_PRIO_TEST and added TCA_PRIO_MQ for sch_prio and sch_rr.

3. Fixed dependancy issues in net/sched/Kconfig with NET_SCH_RR.

4. Implemented the new nested compat attribute API for MQ in NET_SCH_PRIO
   and NET_SCH_RR.

5. Allow sch_rr and sch_prio to turn multiqueue hardware support on and off
   at loadtime.

This patchset is an updated version of previous multiqueue network device
support patches.  The general approach of introducing a new API for multiqueue
network devices to register with the stack has remained.  The changes include
adding a round-robin qdisc, heavily based on sch_prio, which will allow
queueing to hardware with no OS-enforced queuing policy.  sch_prio still has
the multiqueue code in it, but has a Kconfig option to compile it out of the
qdisc.  This allows people with hardware containing scheduling policies to
use sch_rr (round-robin), and others without scheduling policies in hardware
to continue using sch_prio if they wish to have some notion of scheduling
priority.

The patches being sent are split into Documentation, Qdisc changes, and
core stack changes.  The requested e1000 changes are still being resolved,
and will be sent at a later date.

The patches to iproute2 for tc will be sent separately, to support sch_rr.

-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
