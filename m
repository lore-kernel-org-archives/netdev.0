From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 00/12] qed: Add iWARP support for unaligned MPA packets
Date: Mon, 2 Oct 2017 11:23:46 +0300
Message-ID: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0078.outbound.protection.outlook.com ([104.47.33.78]:42080
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750943AbdJBIYW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 04:24:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>

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
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   |  98 +++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h   |   8 +-
 include/linux/qed/qed_ll2_if.h              |   7 +
 5 files changed, 819 insertions(+), 17 deletions(-)

-- 
1.8.3.1
