From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 0/1 v3] drivers: net: Add support for rmnet driver
Date: Thu, 13 Apr 2017 23:05:28 -0600
Message-ID: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58752 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdDNFFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 01:05:40 -0400
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

v2->v3: Move location to drivers/net and rename to rmnet. Change the
userspace - netlink communication from custom netlink to rtnl_link_ops.
Refactor some code. Use a fixed config for ingress and egress.

Subash Abhinov Kasiviswanathan (1):
  drivers: net: rmnet: Initial implementation

 Documentation/networking/rmnet.txt    |  83 +++++
 drivers/net/Kconfig                   |   2 +
 drivers/net/Makefile                  |   1 +
 drivers/net/rmnet/Kconfig             |  23 ++
 drivers/net/rmnet/Makefile            |  14 +
 drivers/net/rmnet/rmnet_config.c      | 592 ++++++++++++++++++++++++++++++++++
 drivers/net/rmnet/rmnet_config.h      |  79 +++++
 drivers/net/rmnet/rmnet_handlers.c    | 517 +++++++++++++++++++++++++++++
 drivers/net/rmnet/rmnet_handlers.h    |  24 ++
 drivers/net/rmnet/rmnet_main.c        |  52 +++
 drivers/net/rmnet/rmnet_map.h         | 100 ++++++
 drivers/net/rmnet/rmnet_map_command.c | 180 +++++++++++
 drivers/net/rmnet/rmnet_map_data.c    | 145 +++++++++
 drivers/net/rmnet/rmnet_private.h     |  76 +++++
 drivers/net/rmnet/rmnet_stats.c       |  86 +++++
 drivers/net/rmnet/rmnet_stats.h       |  61 ++++
 drivers/net/rmnet/rmnet_vnd.c         | 353 ++++++++++++++++++++
 drivers/net/rmnet/rmnet_vnd.h         |  34 ++
 include/uapi/linux/Kbuild             |   1 +
 include/uapi/linux/if_arp.h           |   1 +
 include/uapi/linux/if_ether.h         |   4 +-
 include/uapi/linux/rmnet.h            |  34 ++
 22 files changed, 2461 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/rmnet.txt
 create mode 100644 drivers/net/rmnet/Kconfig
 create mode 100644 drivers/net/rmnet/Makefile
 create mode 100644 drivers/net/rmnet/rmnet_config.c
 create mode 100644 drivers/net/rmnet/rmnet_config.h
 create mode 100644 drivers/net/rmnet/rmnet_handlers.c
 create mode 100644 drivers/net/rmnet/rmnet_handlers.h
 create mode 100644 drivers/net/rmnet/rmnet_main.c
 create mode 100644 drivers/net/rmnet/rmnet_map.h
 create mode 100644 drivers/net/rmnet/rmnet_map_command.c
 create mode 100644 drivers/net/rmnet/rmnet_map_data.c
 create mode 100644 drivers/net/rmnet/rmnet_private.h
 create mode 100644 drivers/net/rmnet/rmnet_stats.c
 create mode 100644 drivers/net/rmnet/rmnet_stats.h
 create mode 100644 drivers/net/rmnet/rmnet_vnd.c
 create mode 100644 drivers/net/rmnet/rmnet_vnd.h
 create mode 100644 include/uapi/linux/rmnet.h

-- 
1.9.1
