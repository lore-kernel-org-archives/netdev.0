From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V6 0/9] liquidio CN23XX VF support
Date: Mon, 14 Nov 2016 15:54:38 -0800
Message-ID: <1479167687-9904-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0060.outbound.protection.outlook.com ([104.47.41.60]:38944
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755180AbcKOA3z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 19:29:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following is the V6 patch series for adding VF support on
CN23XX devices. This version addressed:
1) Your concern for ordering of local variable declarations
   from longest to shortest line.
2) Removed module parameters max_vfs, num_queues_per_{p,v}f.
3) Minor changes for fixing new checkpatch script related 
   errors on pre-existing driver.
4) Fixed compilation issues when CONFIG_PCI_IOV/CONFIG_PCI_ATS
   options are disabled.
5) Modified qualifiers for printing mac addresses with pM format.

I will post remaining VF patches soon after this patchseries is
applied. Please apply patches in the following order as some of
the patches depend on earlier patches.

Thanks.

Raghu Vatsavayi (9):
  liquidio CN23XX: HW config for VF support
  liquidio CN23XX: sysfs VF config support
  liquidio CN23XX: Mailbox support
  liquidio CN23XX: mailbox interrupt processing
  liquidio CN23XX: VF related operations
  liquidio CN23XX: device states
  liquidio CN23XX: code cleanup
  liquidio CN23XX: copyrights changes and alignment
  liquidio CN23XX: fix for new check patch errors

 drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 322 +++++++++++++---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |  44 +--
 .../net/ethernet/cavium/liquidio/cn23xx_pf_regs.h  |  51 ++-
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  49 +--
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |  41 +-
 drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h |  49 ++-
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   |  38 +-
 .../net/ethernet/cavium/liquidio/cn68xx_device.h   |  37 +-
 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h |  37 +-
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  67 +++-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  65 ++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 429 ++++++++++++++++++---
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 100 +++--
 .../net/ethernet/cavium/liquidio/liquidio_image.h  |  36 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  46 ++-
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 156 ++++----
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  79 ++--
 .../net/ethernet/cavium/liquidio/octeon_device.h   | 138 ++++---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  91 +++--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  18 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  25 +-
 .../net/ethernet/cavium/liquidio/octeon_mailbox.c  | 318 +++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_mailbox.h  | 115 ++++++
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  47 +--
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |   7 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.h  |   5 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  11 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |   5 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |   7 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |  34 +-
 .../ethernet/cavium/liquidio/response_manager.c    |  11 +-
 .../ethernet/cavium/liquidio/response_manager.h    |   6 +-
 33 files changed, 1687 insertions(+), 798 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h

-- 
1.8.3.1
