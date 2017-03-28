From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/7] qed: load/unload mfw series
Date: Tue, 28 Mar 2017 15:12:49 +0300
Message-ID: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41193 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751711AbdC1MNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 08:13:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series correct the unload flow and greatly enhances its
initialization flow in regard to interactions between driver
and management firmware.

Patch #1 makes sure unloading is done under management-firmware's
'criticial section' protection.

Patches #2 - #4 move driver into using a newer scheme for loading
in regard to the MFW; This newer scheme would help cleaning the device
in case a previous instance has dirtied it [preboot, PDA, etc.].

Patches #5 - #6 let driver inform management-firmware on number of
resources which are dependent on the non-management firmware used.
Patch #7 then uses a new resource [BDQ] instead of some set value.

Dave,

Please consider applying this series to 'net-next'.

Thanks,
Yuval

Tomer Tayar (4):
  qed: Correct HW stop flow
  qed: Move to new load request scheme
  qed: Support management-based resource locking
  qed: Utilize resource-lock based scheme

Yuval Mintz (3):
  qed: hw_init() to receive parameter-struct
  qed: Send pf-flr as part of initialization
  qed: Use BDQ resource for storage protocols

 drivers/net/ethernet/qlogic/qed/qed.h         |  33 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h    |   3 -
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 579 ++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |  73 ++-
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c    |  30 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h     |  87 ++-
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c   |  32 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c    |  50 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c     | 819 +++++++++++++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_mcp.h     | 179 +++++-
 10 files changed, 1480 insertions(+), 405 deletions(-)

-- 
1.9.3
