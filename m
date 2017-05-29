From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 00/10] qed: DCBx and Attentions series
Date: Mon, 29 May 2017 09:53:04 +0300
Message-ID: <1496040794-6163-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0082.outbound.protection.outlook.com ([104.47.32.82]:47054
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750825AbdE2GxY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 02:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series contains 2 major components [& some odd bits]:
 - The first 3 patches are DCBx-related, containg missing bits in the
   implementation, correcting existing API and removing code no longer
   necessary.
 - Most of the remaining patches are interrupt/hw-attention related,
   adding some differeneces relating to QL41xxx and QL45xxx differences.
   While at it, they also remove a large chunk of unnecessary structure
   definitions.

The series also contain a patch [#10] that was accidently missing
from a previous series.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Changes from previous versions
------------------------------
 - V1 - Correct compilation in #2 to prevent bisection from breaking
      - Some style changes in #6

Sudarsana Reddy Kalluru (3):
  qed: Add missing static/local dcbx info
  qed: Correct DCBx update scheme
  qed: Don't inherit RoCE DCBx for V2

Yuval Mintz (7):
  qed: QL41xxx VF MSI-x table
  qed: Support dynamic s-tag change
  qed: Get rid of the attention-arrays
  qed: Diffrentiate adapter-specific attentions
  qed: Print multi-bit attentions properly
  qed: Mask parities after occurance
  qed: Cache alignemnt padding to match host

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c        |   30 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h        |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_debug.c       |  250 ++++
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |   15 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |   44 +-
 drivers/net/ethernet/qlogic/qed/qed_int.c         | 1466 +++------------------
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |   61 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |    3 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |    9 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |   24 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       |   32 +-
 11 files changed, 593 insertions(+), 1343 deletions(-)

-- 
1.9.3
