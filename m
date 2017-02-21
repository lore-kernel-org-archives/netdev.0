From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv4 net-next 00/13] net: mvpp2: misc improvements and preparation patches
Date: Tue, 21 Feb 2017 11:28:00 +0100
Message-ID: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@arm.linux.org.uk>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:49510 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751788AbdBUK2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 05:28:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

This series contains a number of fixes, misc improvements and
preparation patches for an upcoming series that adds support for the
new PPv2.2 network controller to the mvpp2 driver.

The most significant improvements are:

 - Switching to using build_skb(), which is necessary for the upcoming
   PPv2.2 support, but anyway a good improvement to the current mvpp2
   driver (supporting PPv2.1).

 - Making the driver build on 64-bit platforms.

Changes since v3:

 - Addition of a patch "net: mvpp2: fix DMA address calculation in
   mvpp2_txq_inc_put()", which fixes a bug in the driver in the
   calculation of DMA addresses. This bug was found using
   DMA_API_DEBUG.

 - Modify the "net: mvpp2: switch to build_skb() in the RX path" patch
   to recalculate the fragment size when the MTU is changed in
   mvpp2_bm_update_mtu().

 - Added Acked-by from Russell King on all patches, except:

    * "net: mvpp2: fix DMA address calculation in
      mvpp2_txq_inc_put()", because it's a new patch

    * "net: mvpp2: switch to build_skb() in the RX path" because I
      modified it since the v3.

 - Rebased on top of 4.10.

Changes since v2:

 - Fix remaining 64-bit build warning, reported by David Miller.

 - Adjust how bit mask related definitions are done in "net: mvpp2:
   simplify MVPP2_PRS_RI_* definitions" according to Russell King
   suggestions.

 - Add a patch "net: mvpp2: remove useless arguments in
   mvpp2_rx_{pkts,time}_coal_set", suggested by Russell King.

 - Rework mvpp2_rx_time_coal_set() implementation to avoid overflows
   and rounding errors. I've used the implementation suggested by
   Russell King.

Changes since v1:

 - This series is split as a separate series from the larger patch set
   adding support for PPv2.2 in the mvpp2 driver, as requested by
   David Miller.

 - Rebased on top of v4.10-rc1.

Thanks!

Thomas

Thomas Petazzoni (13):
  net: mvpp2: fix DMA address calculation in mvpp2_txq_inc_put()
  net: mvpp2: remove useless arguments in mvpp2_rx_{pkts,time}_coal_set
  net: mvpp2: handle too large value handling in
    mvpp2_rx_pkts_coal_set()
  net: mvpp2: handle too large value in mvpp2_rx_time_coal_set()
  net: mvpp2: release reference to txq_cpu[] entry after unmapping
  net: mvpp2: remove unused 'tx_skb' field of 'struct mvpp2_tx_queue'
  net: mvpp2: drop useless fields in mvpp2_bm_pool and related code
  net: mvpp2: simplify mvpp2_bm_bufs_add()
  net: mvpp2: remove unused register definitions
  net: mvpp2: fix indentation of MVPP2_EXT_GLOBAL_CTRL_DEFAULT
  net: mvpp2: simplify MVPP2_PRS_RI_* definitions
  net: mvpp2: switch to build_skb() in the RX path
  net: mvpp2: enable building on 64-bit platforms

 drivers/net/ethernet/marvell/Kconfig |   3 +-
 drivers/net/ethernet/marvell/mvpp2.c | 212 +++++++++++++++++++++--------------
 2 files changed, 128 insertions(+), 87 deletions(-)

-- 
2.7.4
