From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/7] bnxt_en: Add interface to support RDMA driver.
Date: Tue,  6 Dec 2016 12:09:31 -0500
Message-ID: <1481044178-25193-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        somnath.kotur@broadcom.com, dledford@redhat.com,
        linux-rdma@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33227 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbcLFRKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:10:05 -0500
Received: by mail-pg0-f51.google.com with SMTP id 3so151320380pgd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:10:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds an interface to support a brand new RDMA driver bnxt_re.
The first step is to re-arrange some code so that pci_enable_msix() can
be called during pci probe.  The purpose is to allow the RDMA driver to
initialize and stay initialized whether the netdev is up or down.

Then we make some changes to VF resource allocation so that there is
enough resources to support RDMA.

Finally the last patch adds a simple interface to allow the RDMA driver to
probe and register itself with any bnxt_en devices that support RDMA.
Once registered, the RDMA driver can request MSIX, send fw messages, and
receive some notifications.

David, please consider this series for net-next.  Thanks.

Michael Chan (7):
  bnxt_en: Add bnxt_set_max_func_irqs().
  bnxt_en: Enable MSIX early in bnxt_init_one().
  bnxt_en: Move function reset to bnxt_init_one().
  bnxt_en: Improve completion ring allocation for VFs.
  bnxt_en: Reserve RDMA resources by default.
  bnxt_en: Refactor the driver registration function with firmware.
  bnxt_en: Add interface to support RDMA driver.

 drivers/net/ethernet/broadcom/bnxt/Makefile     |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 360 +++++++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |  22 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  14 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c   | 346 +++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h   |  93 ++++++
 6 files changed, 722 insertions(+), 115 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h

-- 
1.8.3.1
