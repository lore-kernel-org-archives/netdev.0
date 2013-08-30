From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/9] qlcnic: Enhancements and cleanup
Date: Fri, 30 Aug 2013 13:51:15 -0400
Message-ID: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62576 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756725Ab3H3SUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:20:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series contains -
* Enhanced PVID handling for 84xx adapters by
  not indicating PVID configuration to VF driver and
  keeping VF driver in no VLAN configuration mode becasue
  adapter supports VLAN stripping.
* Removed inappropriate usage of inline keyword.
* Enhanced minidump feature by using firmware recommended
  dump capture mask and using CAMRAM register to store
  firmware dump state.
* AER handling support for 83xx adapter.
* Added support for per port eswitch configuration.

Please apply to net-next.

Thanks,
Shahed 


Manish Chopra (2):
  qlcnic: Enhance PVID handling for 84xx adapters
  qlcnic: Remove inline keyword

Pratik Pujar (3):
  qlcnic: Add AER callback handlers.
  qlcnic: Add AER support for 83xx adapter
  qlcnic: Restructuring of qlc_83xx_fw_info structure.

Shahed Shaikh (3):
  qlcnic: Use firmware recommended dump capture mask as default
  qlcnic: Store firmware dump state in CAMRAM register
  qlcnic: Update version to 5.3.50

Sony Chacko (1):
  qlcnic: Add support for per port eswitch configuration

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   29 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   84 +++++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   16 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  220 ++++++++++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |   40 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  152 +++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  119 ++++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   13 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   15 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   13 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |   19 ++-
 11 files changed, 535 insertions(+), 185 deletions(-)
