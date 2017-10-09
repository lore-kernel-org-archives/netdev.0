From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 net-next 00/12] qed: Add iWARP support for unaligned MPA packets
Date: Mon, 9 Oct 2017 12:37:42 +0300
Message-ID: <1507541874-18344-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Ariel Elior" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series adds support for handling unaligned MPA packets.
(FPDUs split over more than one tcp packet).
When FW detects a packet is unaligned it fowards the packet to 
the driver via a light l2 dedicated connection. The driver then 
stores this packet until the remainder of the packet is received.
Once the driver reconstructs the full FPDU, it sends it down
to fw via the ll2 connection. Driver also breaks down any packed
PDUs into separate packets for FW. 

Patches 1-6 are all slight modifications to ll2 to support additional
requirements for the unaligned MPA ll2 client.

Patch 7 opens the additional ll2 connection for iWARP.
Patches 8-12 contain the algorithm for aligning packets.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
No changes from v2:
	Request for changes in ll2 rxq completion locking is deferred
	to a separate patch series.
	
Michal Kalderon (12):
  qed: Add ll2 option to limit the number of bds per packet
  qed: Add ll2 ability of opening a secondary queue
  qed: Add ll2 option for dropping a tx packet
  qed: Fix initialization of ll2 offload feature
  qed: Add the source of a packet sent on an iWARP ll2 connection
  qed: Add LL2 slowpath handling
  qed: Add ll2 connection for processing unaligned MPA packets
  qed: Add mpa buffer descriptors for storing and processing mpa fpdus
  qed: Add unaligned and packed packet processing
  qed: Add support for freeing two ll2 buffers for corner cases
  qed: Add support for MPA header being split over two tcp packets
  qed: Add iWARP support for fpdu spanned over more than two tcp packets

 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 690 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h |  33 ++
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   | 102 +++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h   |  10 +-
 include/linux/qed/qed_ll2_if.h              |   7 +
 5 files changed, 822 insertions(+), 20 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
