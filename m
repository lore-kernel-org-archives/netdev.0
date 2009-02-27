From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 00/11] Add support to FCoE offload through net_device (v2)
Date: Fri, 27 Feb 2009 14:06:32 -0800
Message-ID: <20090227220034.4987.50755.stgit.yi.zou@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19948 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754533AbZB0XOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 18:14:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is set of revised patches for adding offload support of
Fiber Channel over Ethernet (FCoE) offload support through net_device
for the Open-FCoE project maintained at http://www.open-fcoe.org.

The original submission can be found at:
http://marc.info/?l=linux-scsi&m=123507707821705&w=2

The included patches would add FCoE offload support through the net_device
struct as shown in the series of patches followed here. This is achieved
by adding nedev feature flags for FCoE FC CRC offload and large send offload
through gso. The large receive offload by direct data placement (ddp) is
achieved by the two function pointers to net_device_ops, to setup and release
ddp context, ndo_fcoe_ddp_setup and ndo_fcoe_ddp_done. One data member is
added to net_device strut, namely fcoe_ddp_xid, which inidates the maximum
exchange id allowed by LLD to perform ddp on the read I/O request.

As the following patches touch both netdev and libfc/fcoe, and they are
applicable to the current tip at www.open-fcoe.org w/ patches available at:
http://marc.info/?l=linux-scsi&m=123576089125544&w=2 If they look alright,
I will rework them later to be directly applicable to net-next, where the
aforementioned fcoe/libfc fix patches are expected to be in kernel already
through scsi-fixes.

Thanks.

yi
---

Chris Leech (2):
      net: define feature flags for FCoE offloads
      net: reclaim 8 upper bits of the netdev->features from GSO

Yi Zou (9):
      fcoe: fcoe fc crc offload indication by skb->ip_summed
      fcoe: add support to FCoE offload support in fcoe_sw through net_device
      libfc: add support of large receive offload by ddp in fc_fcp
      fcoe: add support to large send by gso through net_device for fcoe_sw
      libfc: use lso_max for sequence offload
      fcoe,libfc: check offload features from LLD through netdev
      net: add FCoE offload support through net_device
      net: add NETIF_F_FCOE_CRC to can_checksum_protocol
      net,fcoe: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)


 drivers/net/xen-netfront.c   |    2 +
 drivers/scsi/fcoe/fcoe_sw.c  |   67 ++++++++++++++++++++++++++++++++++++++++-
 drivers/scsi/fcoe/libfcoe.c  |   16 ++++++++--
 drivers/scsi/libfc/fc_exch.c |    4 ++
 drivers/scsi/libfc/fc_fcp.c  |   69 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_ether.h     |    1 +
 include/linux/netdevice.h    |   18 ++++++++++-
 include/linux/skbuff.h       |    2 +
 include/scsi/fc/fc_fcoe.h    |    7 ----
 include/scsi/fc_frame.h      |   19 +-----------
 include/scsi/libfc.h         |   31 +++++++++++++++++++
 include/scsi/libfcoe.h       |   18 -----------
 net/core/dev.c               |    4 ++
 13 files changed, 206 insertions(+), 52 deletions(-)

-- 
Signature: Yi Zou <yi.zou@intel.com>
