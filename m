From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/5] net: Add helper for padding short Ethernet
 frames
Date: Tue, 25 Nov 2014 14:43:54 -0800
Message-ID: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbaKYWn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 17:43:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a helper to pad short Ethernet frames.  The general
idea is to clean up a number of code paths that were all writing their own
versions of the same or similar function.

An added advantage is that this will help to discourage introducing new
bugs as in at least one case I found the skb->len had been updated, but the
tail pointer update was overlooked.

---

Alexander Duyck (5):
      etherdevice: Add function for handling padding frame to ETH_ZLEN
      ethernet/intel: Use eth_skb_pad helper
      niu: Use eth_skb_pad helper
      myri10ge: use eth_skb_pad helper
      r8169: Use eth_skb_pad function


 drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   11 +++--------
 drivers/net/ethernet/intel/igb/igb_main.c         |   11 +++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   11 +++--------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++--------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c  |   15 +++++----------
 drivers/net/ethernet/realtek/r8169.c              |   12 ++----------
 drivers/net/ethernet/sun/niu.c                    |    9 ++-------
 include/linux/etherdevice.h                       |   21 +++++++++++++++++++++
 9 files changed, 44 insertions(+), 65 deletions(-)

--
