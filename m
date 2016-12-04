From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V2 net 00/20] Increase ENA driver version to 1.1.2
Date: Sun,  4 Dec 2016 15:19:18 +0200
Message-ID: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes between V1 and V2:
* reorder the patches so the bug fixes will appear first.
* fix the commit message of removing a tuple filter. The first patch
stated mistakenly that it removes RFS.
* add another bug fix (fix RSS default hash configuration).
* split the driver's version increase to a dedicated patch.
* add this patchset description.

This patchset contains mainly bug fixes.
Most of them are critical for the driver and system functionality.
In addition to the bug fixes, this patchset also introduces some minor
Improvements listed below.

Bug fixes:
net/ena: remove ntuple filter support from device feature list
net/ena: fix error handling when probe fails
net/ena: fix queues number calculation
net/ena: fix ethtool RSS flow configuration
net/ena: fix RSS default hash configuration
net/ena: fix NULL dereference when removing the driver after device
reset faild
net/ena: refactor ena_get_stats64 to be atomic context safe
net/ena: add hardware hints capability to the driver
net/ena: fix potential access to freed memory during device reset
net/ena: remove redundant logic in napi callback for busy poll mode
net/ena: use READ_ONCE to access completion descriptors
net/ena: reduce the severity of ena printouts
net/ena: change driver's default timeouts
net/ena: change condition for host attribute configuration
net/ena: change sizeof() argument to be the type pointer

Other improvments:
net/ena: change sizeof() argument to be the type pointer
net/ena: use napi_schedule_irqoff when possible
net/ena: add IPv6 extended protocols to ena_admin_flow_hash_proto
net/ena: remove affinity hint from the driver
net/ena: restructure skb allocation
net/ena: increase driver version to 1.1.2

Netanel Belgazal (20):
  net/ena: remove ntuple filter support from device feature list
  net/ena: fix error handling when probe fails
  net/ena: fix queues number calculation
  net/ena: fix ethtool RSS flow configuration
  net/ena: fix RSS default hash configuration
  net/ena: fix NULL dereference when removing the driver after device
    reset faild
  net/ena: refactor ena_get_stats64 to be atomic context safe
  net/ena: add hardware hints capability to the driver
  net/ena: fix potential access to freed memory during device reset
  net/ena: remove redundant logic in napi callback for busy poll mode
  net/ena: use READ_ONCE to access completion descriptors
  net/ena: reduce the severity of ena printouts
  net/ena: change driver's default timeouts
  net/ena: change condition for host attribute configuration
  net/ena: change sizeof() argument to be the type pointer
  net/ena: use napi_schedule_irqoff when possible
  net/ena: add IPv6 extended protocols to ena_admin_flow_hash_proto
  net/ena: remove affinity hint from the driver
  net/ena: restructure skb allocation
  net/ena: increase driver version to 1.1.2

 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  57 +++-
 drivers/net/ethernet/amazon/ena/ena_com.c        |  98 ++++---
 drivers/net/ethernet/amazon/ena/ena_com.h        |   6 +
 drivers/net/ethernet/amazon/ena/ena_eth_com.c    |   8 +-
 drivers/net/ethernet/amazon/ena/ena_ethtool.c    |   1 -
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 326 ++++++++++++++++-------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |  30 ++-
 drivers/net/ethernet/amazon/ena/ena_regs_defs.h  |   2 +
 8 files changed, 385 insertions(+), 143 deletions(-)

-- 
2.7.4
