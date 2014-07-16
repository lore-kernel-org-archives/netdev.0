From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb4i: Add ipv6 support
Date: Tue, 15 Jul 2014 19:55:49 -0700
Message-ID: <1405479353-2289-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com, hch@infradead.org,
	michaelc@cs.wisc.edu, jbottomley@parallels.com, kxie@chelsio.com,
	leedom@chelsio.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:51479
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753737AbaGPC63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 22:58:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
   The following patchset add ipv6 support for the cxgb4i(iscsi) driver.

Patch 1 moves a define from the iw_cxgb4 to cxgb4 to prevent code duplication,
 as it is used by cxgb4i and iw_cxgb4 both.
Patch 2 exports symbols needed by cxgb4i for ipv6 support from cxgb4.
Patch 3 & 4 deal with actual ipv6 code in libcxgbi/cxgb4i.

Submitting to net-next as changes were needed in cxgb4/iw_cxgb4, and submitting
to scsi separately would break compilation, cc-ing scsi & rdma.

Anish Bhatt (4):
  cxgb4/iw_cxgb4: Move common defines to cxgb4
  cxgb4: Export symbols required by cxgb4i for ipv6 support and required
    defines
  libcxgbi: Add ipv6 api to driver
  cxgb4i: Add ipv6 code to driver, call into libcxgbi ipv6 api

 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h       |   1 -
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  10 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   4 +
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   3 +
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              | 353 +++++++++++++++++++++---
 drivers/scsi/cxgbi/libcxgbi.c                   | 237 ++++++++++++++--
 drivers/scsi/cxgbi/libcxgbi.h                   |  37 ++-
 7 files changed, 580 insertions(+), 65 deletions(-)

-- 
2.0.1
