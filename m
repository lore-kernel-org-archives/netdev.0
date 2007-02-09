From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/2 REVIEW] Multiple transmit/receive queue kernel
Date: Thu, 08 Feb 2007 16:09:42 -0800
Message-ID: <20070209000942.5155.78998.stgit@gitlost.site>
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Peter Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "David Miller" <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1287 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945934AbXBHXzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 18:55:46 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

The following two patches are submitted for review. Please provide feedback
and comments as usual.

This set of patches implements a generic API for multiqueue-capable
devices to have network stack support to assign multiple flows into each
queue on the NIC.  It provides an interface for non-multiqueue devices
to coexist in a machine running with both types of devices, as well as
providing a modified queuing discipline to assign multiple flows in the
stack to individual queues on the NIC.  This is necessary to alleviate
more head-of-line-blocking issues with different priority flows, where
today QoS only prevents HOLB within the stack, but not in the device.

Some Intel PRO/1000 adapters support this hardware feature, so this
series includes a patch to the e1000 driver to enable this hardware
feature for those devices. You will need to setup the queue's using tc.
Limited queue statistics are available through ethtool for devices that
support multiple queues.

Regards,

Auke Kok
Peter Waskiewicz Jr.

---
These patches apply against commit b892afd1e60132a981b963929e352eabf3306ba2
of branch 'master' from torvalds/linux-2.6.

You can pull these patches through git:

git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 multiqueue

---
Summary:
Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>:
     NET: Multiple queue network device support
     e1000: Implement the new kernel API for multiqueue TX support.

---
 drivers/net/Kconfig               |   13 +
 drivers/net/e1000/e1000.h         |   23 +++
 drivers/net/e1000/e1000_ethtool.c |   43 ++++++
 drivers/net/e1000/e1000_main.c    |  269 +++++++++++++++++++++++++++++++-------
 include/linux/netdevice.h         |   73 ++++++++++
 include/net/sch_generic.h         |    3 
 net/Kconfig                       |   20 ++
 net/core/dev.c                    |   51 +++++++
 net/sched/sch_generic.c           |  117 ++++++++++++++++
 net/sched/sch_prio.c              |  106 ++++++++++++++
 10 files changed, 668 insertions(+), 50 deletions(-)

