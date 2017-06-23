From: <netanel@amazon.com>
Subject: [PATCH V2 net-next 00/11] update ena ethernet driver to version 1.2.0
Date: Fri, 23 Jun 2017 11:21:49 +0300
Message-ID: <1498206120-13805-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:31002 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751217AbdFWIWe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 04:22:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

This patchset contains some new features/improvements that were added
to the ENA driver to increase its robustness and are based on
experience of wide ENA deployment.

Change log:

V2:
* Remove patch that add inline to C-file static function (contradict coding style).
* Remove patch that moves MTU parameter validation in ena_change_mtu() instead of
using the network stack.
* Use upper_32_bits()/lower_32_bits() instead of casting.

Netanel Belgazal (11):
  net: ena: change return value for unsupported features unsupported
    return value
  net: ena: add hardware hints capability to the driver
  net: ena: change sizeof() argument to be the type pointer
  net: ena: add reset reason for each device FLR
  net: ena: add support for out of order rx buffers refill
  net: ena: allow the driver to work with small number of msix vectors
  net: ena: use napi_schedule_irqoff when possible
  net: ena: separate skb allocation to dedicated function
  net: ena: use lower_32_bits()/upper_32_bits() to split dma address
  net: ena: update driver's rx drop statistics
  net: ena: update ena driver to version 1.2.0

 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  31 +++
 drivers/net/ethernet/amazon/ena/ena_com.c        |  85 ++++---
 drivers/net/ethernet/amazon/ena/ena_com.h        |  10 +-
 drivers/net/ethernet/amazon/ena/ena_eth_com.c    |   5 +
 drivers/net/ethernet/amazon/ena/ena_ethtool.c    |  11 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 306 +++++++++++++++++------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |  30 ++-
 drivers/net/ethernet/amazon/ena/ena_regs_defs.h  |  34 +++
 8 files changed, 399 insertions(+), 113 deletions(-)

-- 
2.7.4
