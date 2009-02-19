From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 0/7] Add support to FCoE offload through net_device
Date: Thu, 19 Feb 2009 12:49:32 -0700
Message-ID: <20090219194734.22270.8445.stgit.yi.zou@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I am working on to support offload for Fiber Channel over Ethernet (FCoE) for
the Open-FCoE project maintained at http://www.open-fcoe.org.

I would like to propose adding FCoE offload support through the net_device
struct as shown in the series of patches followed here. The general idea is to
add "struct net_fcoe_ops *fcoe_ops" to net_device, so any network adapter driver
that wants to provides FCoE offload can use fcoe_ops through net_device.

The following patches touch both netdev and libfc/fcoe, where the first two
patches touch netdev, and the rest patches show how the proposed net_fcoe_ops
struct is used in fcoe/libfc through net_deivce to support FCoE offload.

Thanks.

yi
---

Yi Zou (7):
      fcoe: fcoe fc crc offload indication by skb->ip_summed
      fcoe: remove ETH_P_FCOE from fc_fcoe.h
      fcoe: add support to net_fcoe_ops in fcoe_sw
      libfc: add support of large receive offload by ddp in fc_fcp
      fcoe: check offload features from LLD through netdev
      net: add FCoE offload support through net_device
      net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)


 drivers/scsi/fcoe/fcoe_sw.c  |   64 ++++++++++++++++++++++++++++++++++++++++++
 drivers/scsi/fcoe/libfcoe.c  |    2 +
 drivers/scsi/libfc/fc_exch.c |   46 ++++++++++++++++++++----------
 drivers/scsi/libfc/fc_fcp.c  |   36 ++++++++++++++++++++++--
 include/linux/if_ether.h     |    1 +
 include/linux/netdevice.h    |    8 +++++
 include/linux/netfcoe.h      |   36 ++++++++++++++++++++++++
 include/scsi/fc/fc_fcoe.h    |    7 -----
 include/scsi/libfc.h         |   46 ++++++++++++++++++++++++++++++
 9 files changed, 220 insertions(+), 26 deletions(-)
 create mode 100644 include/linux/netfcoe.h

-- 
Signature: Yi Zou <yi.zou@intel.com>
