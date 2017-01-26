From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V3 net-next 00/14] Bug Fixes in ENA driver.
Date: Fri, 27 Jan 2017 00:18:02 +0200
Message-ID: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes between V3 and V2:
* Fix typos and correct alignment in commit messages.
* use napi_complete_done() return value to determine when the napi
handler needs to unmask the interrupts rather than implementing
non standard solution.
* Remove new features from this patchset and leave bug fixes only.
* Give example in the commit message for kernel crashes.
* Use BIT(x) instead of use the value explicitly.


Netanel Belgazal (14):
  net/ena: remove ntuple filter support from device feature list
  net/ena: fix error handling when probe fails
  net/ena: fix queues number calculation
  net/ena: fix ethtool RSS flow configuration
  net/ena: fix RSS default hash configuration
  net/ena: fix NULL dereference when removing the driver after device
    reset failed
  net/ena: refactor ena_get_stats64 to be atomic context safe
  net/ena: fix potential access to freed memory during device reset
  net/ena: use napi_complete_done() return value
  net/ena: use READ_ONCE to access completion descriptors
  net/ena: reduce the severity of ena printouts
  net/ena: change driver's default timeouts
  net/ena: change condition for host attribute configuration
  net/ena: update driver version to 1.1.2

 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  20 ++-
 drivers/net/ethernet/amazon/ena/ena_com.c        |  41 ++---
 drivers/net/ethernet/amazon/ena/ena_com.h        |   1 +
 drivers/net/ethernet/amazon/ena/ena_eth_com.c    |   8 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 186 ++++++++++++++++-------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |   9 +-
 6 files changed, 182 insertions(+), 83 deletions(-)

-- 
2.7.4
