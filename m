From: Alexander Duyck <aduyck@mirantis.com>
Subject: [PATCH 0/3] use napi_schedule_irqoff()
Date: Tue, 29 Sep 2015 15:19:37 -0700
Message-ID: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34094 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756707AbbI2WTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:19:40 -0400
Received: by padhy16 with SMTP id hy16so17901549pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:19:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is meant to replace the calls to napi_schedule with
napi_schedule_irqoff as this should help to reduce the interrupt overhead
slightly by removing the unneeded call to local_irq_save and
local_irq_restore.

---

Alexander Duyck (3):
      ixgbe/ixgbevf: use napi_schedule_irqoff()
      i40e/i40evf: use napi_schedule_irqoff()
      fm10k: use napi_schedule_irqoff()


 drivers/net/ethernet/intel/fm10k/fm10k_pci.c      |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c       |    6 ++++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 5 files changed, 9 insertions(+), 7 deletions(-)

--
