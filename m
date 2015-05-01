From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net PATCH 0/3] Clean-up some bits related to netpoll
Date: Fri, 01 May 2015 10:34:32 -0700
Message-ID: <20150501173049.1029.54421.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, davem@davemloft.net
To: netdev@vger.kernel.org, nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbbEARej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 13:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set cleans up some minor items related to netpoll.  The first
patch addresses an Rx clean-up bug that is triggered due to an assumption
that napi->poll wouldn't be called with a budget of 0.  The other two
patches address dev_kfree_skb being called in the xmit path which isn't
valid since netpoll will call ndo_start_xmit with IRQs disabled.

---

Alexander Duyck (3):
      fm10k: Do not assume budget will never be 0 for NAPI
      r8169: Do not use dev_kfree_skb in xmit path
      ixgbevf: Use dev_kfree_skb_any in xmit path, not dev_kfree_skb


 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |    4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/ethernet/realtek/r8169.c              |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

--
