From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 0/1 v2] net: Add support for rmnet_data driver
Date: Mon, 13 Mar 2017 01:43:08 -0600
Message-ID: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43056 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbdCMHnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the rmnet_data driver which is required to
support recent chipsets using Qualcomm Technologies, Inc. modems. The data
from hardware follows the multiplexing and aggregation protocol (MAP).

This driver can be used to register onto any physical network device in
IP mode. Physical transports include USB, HSIC, PCIe and IP accelerator.

rmnet_data driver helps to decode these packets and queue them to network
stack (and encode and transmit it to the physical device).

--
v1: Same as the RFC patch with some minor fixes for issues reported by
kbuild test robot.

v1->v2: Change datatypes and remove config IOCTL as mentioned by David.
Also fix checkpatch issues and remove some unused code.

Subash Abhinov Kasiviswanathan (1):
  net: rmnet_data: Initial implementation

 Documentation/networking/rmnet_data.txt |   82 +++
 include/uapi/linux/Kbuild               |    1 +
 include/uapi/linux/if_arp.h             |    1 +
 include/uapi/linux/if_ether.h           |    4 +-
 include/uapi/linux/rmnet_data.h         |  214 ++++++
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/rmnet_data/Kconfig                  |   21 +
 net/rmnet_data/Makefile                 |   14 +
 net/rmnet_data/rmnet_data_config.c      | 1168 +++++++++++++++++++++++++++++++
 net/rmnet_data/rmnet_data_config.h      |  107 +++
 net/rmnet_data/rmnet_data_handlers.c    |  556 +++++++++++++++
 net/rmnet_data/rmnet_data_handlers.h    |   24 +
 net/rmnet_data/rmnet_data_main.c        |   60 ++
 net/rmnet_data/rmnet_data_private.h     |   76 ++
 net/rmnet_data/rmnet_data_stats.c       |   86 +++
 net/rmnet_data/rmnet_data_stats.h       |   61 ++
 net/rmnet_data/rmnet_data_trace.h       |  198 ++++++
 net/rmnet_data/rmnet_data_vnd.c         |  460 ++++++++++++
 net/rmnet_data/rmnet_data_vnd.h         |   34 +
 net/rmnet_data/rmnet_map.h              |  100 +++
 net/rmnet_data/rmnet_map_command.c      |  180 +++++
 net/rmnet_data/rmnet_map_data.c         |  148 ++++
 23 files changed, 3596 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/rmnet_data.txt
 create mode 100644 include/uapi/linux/rmnet_data.h
 create mode 100644 net/rmnet_data/Kconfig
 create mode 100644 net/rmnet_data/Makefile
 create mode 100644 net/rmnet_data/rmnet_data_config.c
 create mode 100644 net/rmnet_data/rmnet_data_config.h
 create mode 100644 net/rmnet_data/rmnet_data_handlers.c
 create mode 100644 net/rmnet_data/rmnet_data_handlers.h
 create mode 100644 net/rmnet_data/rmnet_data_main.c
 create mode 100644 net/rmnet_data/rmnet_data_private.h
 create mode 100644 net/rmnet_data/rmnet_data_stats.c
 create mode 100644 net/rmnet_data/rmnet_data_stats.h
 create mode 100644 net/rmnet_data/rmnet_data_trace.h
 create mode 100644 net/rmnet_data/rmnet_data_vnd.c
 create mode 100644 net/rmnet_data/rmnet_data_vnd.h
 create mode 100644 net/rmnet_data/rmnet_map.h
 create mode 100644 net/rmnet_data/rmnet_map_command.c
 create mode 100644 net/rmnet_data/rmnet_map_data.c

-- 
1.9.1
