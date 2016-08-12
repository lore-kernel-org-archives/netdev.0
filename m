From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 00/21] net: thunderx: Support for newer chips and miscellaneous patches
Date: Fri, 12 Aug 2016 16:51:23 +0530
Message-ID: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series adds support for VNIC on 81xx and 83xx SOCs.
81xx/83xx is different from 88xx in terms of capabilities and new type
of interfaces supported (eg: QSGMII, RGMII) and have DLMs instead of
QLMs which allows single BGX to have interfaces of different LMAC types.

Also included some patches which are common for all 88xx/81xx/83xx
SOCs like using netdev's name while registering irqs, reset receive
queue stats and some changes to use standard API for split buffer Rx
packets, generating RSS key e.t.c

PS: Most of the patches were submitted earlier under different series but
for some reason were not picked up by patchwork. Since new patches have been
added in the meantime, resubmitting all as a new patchset.

Changes from v1:
- Incorporated Yuval Mintz's suggestion to use generic API to set minimum
  queue count i.e by using netif_get_num_default_rss_queues().
- Resolved a compilation issue reported by test robot while compiling
  patch 'Add support for 16 LMACs of 83xx'

Jerin Jacob (1):
  net: thunderx: Reset RXQ HW stats when interface is brought down

Radoslaw Biernacki (1):
  net: thunderx: Improvement for MBX interface debug messages

Sunil Goutham (18):
  net: thunderx: Moved HW capability info from macros to structure
  net: thunderx: Add VNIC's PCI devid on future chips
  net: thunderx: Add support for 81xx and 83xx chips
  net: thunderx: Set queue count based on number of CPUs
  net: thunderx: Enable CQE_RX desc's extension fields
  net: thunderx: Enable mailbox interrupts on 81xx/83xx
  net: thunderx: Support for different LMAC types within BGX
  net: thunderx: Add 81xx support to BGX driver
  net: thunderx: Add QSGMII interface type support
  net: thunderx: Add RGMII interface type support
  net: thunderx: Add support for 16 LMACs of 83xx
  net: thunderx: Support for 83xx mixed QLM/DLM config
  net: thunderx: Use netdev's name for naming VF's interrupts
  net: thunderx: Use skb_add_rx_frag() for split buffer Rx pkts
  net: thunderx: Don't set mac address for secondary Qset VFs
  net: thunderx: Use napi_consume_skb for bulk free
  net: thunderx: Use netdev_rss_key_fill() helper
  net: thunderx: Don't set RX_PACKET_DIS while initializing

Zyta Szpak (1):
  net: thunderx: Configure tunnelling protocol parsing

 drivers/net/ethernet/cavium/Kconfig                |  10 +
 drivers/net/ethernet/cavium/thunder/Makefile       |   1 +
 drivers/net/ethernet/cavium/thunder/nic.h          |  85 ++--
 drivers/net/ethernet/cavium/thunder/nic_main.c     | 433 +++++++++++++++----
 drivers/net/ethernet/cavium/thunder/nic_reg.h      |  15 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  67 +--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  59 +--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   5 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  | 460 ++++++++++++++-------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |  33 +-
 drivers/net/ethernet/cavium/thunder/thunder_xcv.c  | 237 +++++++++++
 11 files changed, 1059 insertions(+), 346 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_xcv.c

-- 
2.7.4
