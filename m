From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 00/14] qed*: Add SR-IOV support
Date: Wed, 11 May 2016 16:36:11 +0300
Message-ID: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:24992 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932271AbcEKNgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:36:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds SR-IOV support to qed/qede drivers, adding a new PCI
device ID for a VF that is shared between all the various PFs that
support IOV.

This is quite a massive series - the first 7 parts of the series add
the infrastructure of supporting vfs in qed - mainly adding support in a
HW-based vf<->pf channel, as well as diverging all existing configuration
flows based on the pf/vf decision. I.e., while PF-originated requests
head directly to HW/FW, the VF requests first have to traverse to the PF
which will perform the configuration.

The 8th patch is the one that adds the support for the VF device in qede.

The remaining 6 patches each adds some user-based API support related to
VFs that can be used over the PF - forcing mac/vlan, changing speed, etc.

Dave,

Sorry in advance for the length of the series. Most of the bulk here is in
the infrastructure patches that have to go together [or at least, it makes
little sense to try splitting them up].

Please consider applying this to `net-next'.

Thanks,
Yuval

Changes from previous revision:
------------------------------
 - V2 - Replace aligned_u64 with regular u64; This was possible as the
        shared structures [between PF and VF] were already sufficiently
        padded as-is in the API, making this redundant.

Yuval Mintz (14):
  qed: Add CONFIG_QED_SRIOV
  qed: Add VF->PF channel infrastructure
  qed: Introduce VFs
  qed: IOV configure and FLR
  qed: IOV l2 functionality
  qed: Bulletin and Link
  qed: Align TLVs
  qede: Add VF support
  qed*: Support PVID configuration
  qed*: Support forced MAC
  qed*: IOV link control
  qed*: IOV support spoof-checking
  qed*: Support ndo_get_vf_config
  qed*: Tx-switching configuration

 drivers/net/ethernet/qlogic/Kconfig               |   10 +
 drivers/net/ethernet/qlogic/qed/Makefile          |    1 +
 drivers/net/ethernet/qlogic/qed/qed.h             |   21 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c         |  186 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h         |    3 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  308 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |   31 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |   60 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.c          |   67 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.h          |   10 +
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c    |    4 +
 drivers/net/ethernet/qlogic/qed/qed_int.c         |  101 +-
 drivers/net/ethernet/qlogic/qed/qed_int.h         |   16 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c          |  641 ++--
 drivers/net/ethernet/qlogic/qed/qed_l2.h          |  239 ++
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  208 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |  155 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h         |   39 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |   18 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |    6 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |   13 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c         |   19 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       | 3606 +++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h       |  386 +++
 drivers/net/ethernet/qlogic/qed/qed_vf.c          | 1102 +++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h          |  990 ++++++
 drivers/net/ethernet/qlogic/qede/qede.h           |    4 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c   |   43 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c      |  183 +-
 include/linux/qed/common_hsi.h                    |   62 +
 include/linux/qed/qed_eth_if.h                    |    9 +
 include/linux/qed/qed_if.h                        |   11 +-
 include/linux/qed/qed_iov_if.h                    |   34 +
 33 files changed, 8130 insertions(+), 456 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_l2.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sriov.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sriov.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_vf.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_vf.h
 create mode 100644 include/linux/qed/qed_iov_if.h

-- 
1.9.3
