From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH v2 net-next 0/5] SR-IOV and FW-dump enhancements
Date: Fri, 9 May 2014 02:51:28 -0400
Message-ID: <1399618293-28633-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:22316 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079AbaEIHUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 03:20:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contain following enhancements.

* SR-IOV enhancements:
 - Allow SR-IOV VF's to probe in hypervisor. SR-IOV VF can be
   uplinked to bridge/macvtap device with this change.
 - Commands from VF are processed in process context
   as it may sleep during PF-VF communication. Earlier
   we use to process qlcnic_sriov_vf_set_multi function in 
   process context but now we process individual commands.
 - As SR-IOV VF's can be uplinked to bridge/macvtap device
   support mac-learning to allow communication through 
   embedded switch.

* FW-dump enhancement:
 - Support to collect RDMEM section of firmware dump using 
   PEX DMA method for 82xx series adapter. 

* Changes in v2:
 - Removed unnecessary cast from void pointer to something
   else and verified this issue in entire patch series as
   per David Miller's suggestion.

Please apply this series to net-next.

Thanks,
Rajesh
 
Rajesh Borundia (4):
  qlcnic: Allow SR-IOV VF probe in hypervisor.
  qlcnic: Add support to process commands in atomic context
  qlcnic: Add mac learning support to SR-IOV VF.
  qlcnic: Update version to 5.3.59

Shahed Shaikh (1):
  qlcnic: Collect firmware dump using DMA on 82xx adapters

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   18 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   31 +---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   12 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   32 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   12 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   25 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   37 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    4 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |  188 ++++++++++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   84 +++++----
 11 files changed, 244 insertions(+), 203 deletions(-)
