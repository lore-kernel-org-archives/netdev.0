From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH V2 0/4] Add IPv6 support for iWARP
Date: Wed, 12 Jun 2013 17:11:38 +0530
Message-ID: <1371037302-3586-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	tom@opengridcomputing.com, faisal.latif@intel.com,
	akpm@linux-foundation.org, sasha.levin@oracle.com,
	nirranjan@chelsio.com, vipul@chelsio.com
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12975 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab3FLLsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 07:48:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series adds IPv6 support for iWARP. It enables Chelsio's T4 and T5
adapters to transmitt RDMA traffic over IPv6 address. It adds new apis and cpl
messages in cxgb4 to support IPv6 operations and uses them in RDMA/cxgb4.

The patch series  modifies the type of local_addr and remote_addr fields in
struct iw_cm_id from struct sockaddr_in to struct sockaddr_storage to hold IPv6
and IPv4 addresses uniformly. It changes the references of local_addr and
remote_addr in RDMA/cxgb4, RDMA/cxgb3, RDMA/nes and amso drivers such that build
failure is avoided.

We would like to submit this patch series via Roland's infiniband tree for-next
branch. However the series requires the latest changes pushed in cxgb4 driver in
David Miller's net-next tree. We request Roland to merge cxgb4 and RDMA/cxgb4
drivers from net-next tree before applying this series on for-next branch. We
have created this patch series on top of net-next tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks,
Vipul Pandya

V2: Used local variables instead of typecasting in patch 1/4.

Steve Wise (1):
  RDMA/cma: Add IPv6 support for iWARP.

Vipul Pandya (3):
  cxgb4: Add routines to create and remove listening IPv6 servers
  cxgb4: Add CLIP support to store compressed IPv6 address
  RDMA/cxgb4: Add support for active and passive open connection with
    IPv6 address

 drivers/infiniband/core/cma.c                   |  69 +-
 drivers/infiniband/hw/amso1100/c2_ae.c          |  18 +-
 drivers/infiniband/hw/amso1100/c2_cm.c          |  16 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c           |  46 +-
 drivers/infiniband/hw/cxgb4/cm.c                | 842 ++++++++++++++++--------
 drivers/infiniband/hw/cxgb4/device.c            | 116 +++-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   4 +-
 drivers/infiniband/hw/nes/nes_cm.c              | 148 +++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 277 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   5 +
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |  17 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  23 +
 include/rdma/iw_cm.h                            |   8 +-
 13 files changed, 1142 insertions(+), 447 deletions(-)

-- 
1.8.0
