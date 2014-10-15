From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv4 RFC net-next 0/4] sunvnet: NAPIfy sunvnet
Date: Wed, 15 Oct 2014 14:00:34 -0400
Message-ID: <20141015180034.GG11840@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: davem@davemloft.net, bob.picco@oracle.com,
	sowmini.varadhan@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com, david.stevens@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patchset converts the sunvnet driver to use the NAPI framework.

Patch 1 in the series addresses the packet-receive path- all
the vnet_event() processing is moved into NAPI context.
This patch is dependant on the sparc-next commit:
  "sparc64: Add vio_set_intr() to enable/disable Rx interrupts"
(Please cherry-pick sparc commit id ca605b7dd740c8909408d67911d8ddd272c2b320)

Patch 2 uses RCU to fix race conditions between vnet_port_remove and
paths that access/modify port-related state, such as vnet_start_xmit.

Patch 3 and Patch 4 in the series leverage from the NAPIfied Rx path, 
dropping superfluous usage of the irqsave/irqrestores on the vio.lock
where possible.

Note: Patch 3 contains changes that target sparc-next, Patch 4 targets
net-next.

Sowmini Varadhan (4):
  NAPIfy sunvnet
  Use RCU to synchronize port usage with vnet_port_remove()
  Avoid irqsave/restore on vio.lock if in_softirq()
  Remove irqsave/irqrestore on vio.lock

 arch/sparc/kernel/viohs.c          |   8 +-
 drivers/net/ethernet/sun/sunvnet.c | 258 +++++++++++++++++++++++--------------
 drivers/net/ethernet/sun/sunvnet.h |   6 +-
 3 files changed, 173 insertions(+), 99 deletions(-)

-- 
1.8.4.2

