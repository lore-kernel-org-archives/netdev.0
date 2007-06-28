From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: Multiple queue hardware support
Date: Thu, 28 Jun 2007 09:20:56 -0700
Message-ID: <20070628162056.18728.20195.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46821 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158AbXF1QVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 12:21:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please consider these patches for 2.6.23 inclusion.

Updates since the last submission:

1. Fixed alloc_netdev_mq() queue_count bug.

2. Fixed the TCA_PRIO_MQ options layout.

3. Protected sch_prio and sch_rr multiqueue code with NET_SCH_MULTIQUEUE.

4. Added RTA_{GET|PUT}_FLAG in place of RTA_DATA for passing multiqueue
   options to and from the qdisc.

5. Allow sch_prio and sch_rr to take 0 bands when in multiqueue mode.  This
   will set q->bands to dev->egress_subqueue_count; added this also to the
   kernel doc.

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
core stack changes.

The patches to iproute2 for tc will be sent separately, to support sch_rr.

-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
