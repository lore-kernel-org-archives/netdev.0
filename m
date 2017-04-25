From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 0/8] Fix and complete CAN namespace support
Date: Tue, 25 Apr 2017 08:19:37 +0200
Message-ID: <20170425061945.28722-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        dev@kicherer.org, netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

unfortunately the initial network namespace support by Mario Kicherer
(8e8cda6d737d) slipped into net-next without further review and Marc pushed
the code without my Acked-by. Due to the fact that this code was in net-next
now I spent some nights to fix, clean up, finalize and test the missing pieces
for the namespace support for the CAN subsystem in net/can.

As Marc is currently *VERY* unresponsive on the mailing list due to his 'real'
job I send this patch set directly to you to make sure it gets through the
current merge window. We are already in -rc8 and I would like to avoid to push
an incomplete functionality - that has to be fixed - to Linus.

This patch set is based on the latest net-next.

Thanks,
Oliver

Oliver Hartkopp (8):
  can: fix memory leak in initial namespace support
  can: remove obsolete pernet_operations definitions
  can: remove obsolete definitions
  can: complete initial namespace support
  can: network namespace support for CAN_BCM protocol
  can: network namespace support for CAN gateway
  can: add Virtual CAN Tunnel driver (vxcan)
  can: enable module auto loading for virtual CAN interfaces

 drivers/net/can/Kconfig        |  18 +++
 drivers/net/can/Makefile       |   1 +
 drivers/net/can/vcan.c         |   7 +-
 drivers/net/can/vxcan.c        | 316 +++++++++++++++++++++++++++++++++++++++++
 include/linux/can/core.h       |   4 +-
 include/net/netns/can.h        |   9 ++
 include/uapi/linux/can/vxcan.h |  12 ++
 net/can/af_can.c               |  77 +++++-----
 net/can/af_can.h               |   9 --
 net/can/bcm.c                  |  90 +++++++-----
 net/can/gw.c                   |  72 ++++++----
 net/can/proc.c                 | 141 +++++++++---------
 12 files changed, 580 insertions(+), 176 deletions(-)
 create mode 100644 drivers/net/can/vxcan.c
 create mode 100644 include/uapi/linux/can/vxcan.h

-- 
2.11.0

