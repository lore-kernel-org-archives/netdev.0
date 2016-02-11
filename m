From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 0/6] net: thunderx: Setting IRQ affinity hints and other optimizations
Date: Thu, 11 Feb 2016 21:50:20 +0530
Message-ID: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series contains changes
- To add support for virtual function's irq affinity hint
- Replace napi_schedule() with napi_schedule_irqoff()
- Reduce page allocation overhead by allocating pages
  of higher order when pagesize is 4KB.
- Add couple of stats which helps in debugging
- Some miscellaneous changes to BGX driver.

Changes from v1:
- As suggested changed MAC address invalid log message 
  to dev_err() instead of dev_warn().

David Daney (1):
  net: thunderx: bgx: Use standard firmware node infrastructure.

Robert Richter (1):
  net: thunderx: bgx: Add log message when setting mac address

Sunil Goutham (3):
  net: thunderx: Use napi_schedule_irqoff()
  net: thunderx: Assign affinity hints to vf's interrupts
  net: thunderx: Alloc higher order pages when pagesize is small

Thanneeru Srinivasulu (1):
  net, thunderx: Add TX timeout and RX buffer alloc failure stats.

 drivers/net/ethernet/cavium/thunder/nic.h          |    4 ++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |    2 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   40 ++++++++++++++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    5 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |   38 +++++++++++--------
 5 files changed, 67 insertions(+), 22 deletions(-)
