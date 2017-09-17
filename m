From: Robert Hoo <robert.hu@linux.intel.com>
Subject: [pktgen script v2 0/2] Add a pktgen sample script of NUMA awareness
Date: Sun, 17 Sep 2017 20:36:36 +0800
Message-ID: <1505651798-106642-1-git-send-email-robert.hu@linux.intel.com>
Cc: netdev@vger.kernel.org, robert.hu@intel.com
To: brouer@redhat.com, davem@davemloft.net, tariqt@mellanox.com,
        kyle.leet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:56558 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750885AbdIQMgq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 17 Sep 2017 08:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Hoo <robert.hu@intel.com>

It's hard to benchmark 40G+ network bandwidth using ordinary
tools like iperf, netperf (see reference 1). 
Pktgen, packet generator from Kernel sapce, shall be a candidate.
I derived this NUMA awared irq affinity sample script from
multi-queue sample02, successfully benchmarked 40G link. I think this can
also be useful for 100G reference, though I haven't got device to test yet.

This script simply does:
Detect $DEV's NUMA node belonging.
Bind each thread (processor of NUMA locality) with each $DEV queue's
irq affinity, 1:1 mapping.
How many '-t' threads input determines how many queues will be
utilized.
If '-f' designates first cpu id, then offset in the NUMA node's cpu
list.

Tested with Intel XL710 NIC with Cisco 3172 switch.

Referrences:
https://people.netfilter.org/hawk/presentations/LCA2015/net_stack_challenges_100G_LCA2015.pdf
http://www.intel.cn/content/dam/www/public/us/en/documents/reference-guides/xl710-x710-performance-tuning-linux-guide.pdf

Change log
v2:
	Rebased to https://github.com/netoptimizer/network-testing/tree/master/pktgen
	Move helper functions to functions.sh
	More concise shell grammar usage
	Take '-f' parameter into consideration. If the first CPU is designaed,
offset in the NUMA-aware CPU list.
	Use err(), info() helper functions for such outputs.

Robert Hoo (2):
  Add some helper functions
  Add pktgen script: pktgen_sample06_numa_awared_queue_irq_affinity.sh

 pktgen/functions.sh                                | 44 ++++++++++
 ...tgen_sample06_numa_awared_queue_irq_affinity.sh | 97 ++++++++++++++++++++++
 2 files changed, 141 insertions(+)
 create mode 100755 pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh

-- 
1.8.3.1
