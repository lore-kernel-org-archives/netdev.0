From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH v8 0/2] Series short description
Date: Mon, 17 Jan 2011 10:05:58 -0800
Message-ID: <20110117175542.29543.38690.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jarkao2@gmail.com, hadi@cyberus.ca,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tgraf@infradead.org,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32768 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab1AQSKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 13:10:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed from v7, Ben Hutchings wants to actively manage queues
from the ndo_setup_tc() routine. Presumably to change the number
of tx queues creating n queues per traffic class. I agreed so
this version updates the patch to work correctly in this case.

Previously I was calling ndo_setup_tc from netif_set_num_tx_queues(),
to verify the queue offset/count but this would break any
queue management so this is removed. Now the mappings are
invalidated if the mapping requires it and it is expected
that the netdevice configured a valid mapping so calling
back into the driver is not needed. Validation is still
required in the case of a netdevice that does not
implement ndo_setup_tc() or to recover in cases where
ndo_open is adjusting number of queues do to resource
constraints.

Finally added some documentation to netdevice.h regarding
the new ops routine.

---

John Fastabend (2):
      net_sched: implement a root container qdisc sch_mqprio
      net: implement mechanism for HW based QOS


 include/linux/netdevice.h |   68 +++++++
 include/linux/pkt_sched.h |   12 +
 net/core/dev.c            |   55 ++++++
 net/sched/Kconfig         |   12 +
 net/sched/Makefile        |    1 
 net/sched/sch_generic.c   |    4 
 net/sched/sch_mqprio.c    |  417 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 568 insertions(+), 1 deletions(-)
 create mode 100644 net/sched/sch_mqprio.c

-- 
Signature
