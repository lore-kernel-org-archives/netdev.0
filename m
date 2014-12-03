From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v2 0/6] net: Add helper for padding short Ethernet frames
Date: Wed, 03 Dec 2014 08:17:26 -0800
Message-ID: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbaLCQRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 11:17:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a pair of helpers to pad short Ethernet frames.  The
general idea is to clean up a number of code paths that were all writing
their own versions of the same or similar function.

An added advantage is that this will help to discourage introducing new
bugs as in at least one case I found the skb->len had been updated, but the
tail pointer update was overlooked.

v2: Added skb_put_padto for cases where length is not ETH_ZLEN
    Updated intel drivers and emulex driver to use skb_put_padto
    Updated eth_skb_pad to use skb_put_padto

---

Alexander Duyck (6):
      net: Add functions for handling padding frame and adding to length
      ethernet/intel: Use eth_skb_pad and skb_put_padto helpers
      emulex: Use skb_put_padto instead of skb_padto() and skb->len assignment
      niu: Use eth_skb_pad helper
      myri10ge: use eth_skb_pad helper
      r8169: Use eth_skb_pad function


 drivers/net/ethernet/emulex/benet/be_main.c       |    3 +--
 drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++-----
 drivers/net/ethernet/intel/e1000e/netdev.c        |    8 ++-----
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   11 +++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    8 ++-----
 drivers/net/ethernet/intel/igb/igb_main.c         |   19 ++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   19 ++++-------------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++-------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c  |   15 ++++---------
 drivers/net/ethernet/realtek/r8169.c              |   12 ++---------
 drivers/net/ethernet/sun/niu.c                    |    9 ++------
 include/linux/etherdevice.h                       |   12 +++++++++++
 include/linux/skbuff.h                            |   24 ++++++++++++++++++++-
 13 files changed, 67 insertions(+), 92 deletions(-)

--
