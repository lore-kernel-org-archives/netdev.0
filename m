From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 0/3] netpoll fixes for Intel drivers
Date: Tue, 22 Sep 2015 14:35:22 -0700
Message-ID: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34341 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934184AbbIVVfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 17:35:24 -0400
Received: by padhy16 with SMTP id hy16so20144424pad.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 14:35:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While reviewing some other patches related to netpoll I started looking at
how the drivers were handling their budgets.  It turns out that the ixgbe,
fm10k, and i40e drivers contained cases where they would increase the
budget from 0 and as a result it was possible for them to clean Rx frames
inside of netpoll context.

This patch set corrects that by adding a check before the Rx portion of the
polling routines for a budget less than or equal to 0.  If the value is in
that range we simply exit and leave ourselves on the polling list rather
than attempt to clean any Rx frames.

---

Alexander Duyck (3):
      i40e: Fix handling of napi budget
      fm10k: Fix handling of napi budget when multiple queues are enabled per vector
      ixgbe: Fix handling of napi budget when multiple queues are enabled per vector


 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    4 ++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 ++-
 3 files changed, 11 insertions(+), 1 deletion(-)

--
