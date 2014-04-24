From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-04-24
Date: Fri, 25 Apr 2014 00:00:03 +0200
Message-ID: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request for net/master, for the v3.15 release cycle, consisting
of 26 patches.

Thomas Gleixner contributes 21 patches for the c_can driver, which address
several shortcomings in the driver like hardware initialisation, concurrency,
message ordering and poor performance. Two patches Oliver Hartkopp, one adds a
missing lock to the sja1000_isa driver, the other one fixes the return value in
the generic bit time configuration function. And finally a patch by Alexander
Stein, that fixes the slcan driver to use the correct spinlock variant.

regards,
Marc

---

The following changes since commit a64d90fd962c2956da7505f98a302408450365e2:

  netfilter: Fix warning in nfnetlink_receive(). (2014-04-24 13:51:29 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.15-20140424

for you to fetch changes up to 367525c8c20a34560afe1d0c7cca52a44ccd62e9:

  can: slcan: Fix spinlock variant (2014-04-24 22:32:41 +0200)

----------------------------------------------------------------
linux-can-fixes-for-3.15-20140424

----------------------------------------------------------------
Alexander Stein (1):
      can: slcan: Fix spinlock variant

Oliver Hartkopp (2):
      can: sja1000_isa: add locking for indirect register access mode
      can: fix return value from can_get_bittiming()

Thomas Gleixner (21):
      can: c_can_pci: Set the type of the IP core
      can: c_can: Fix startup logic
      can: c_can: Make bus off interrupt disable logic work
      can: c_can: Do not access skb after net_receive_skb()
      can: c_can: Handle state change correctly
      can: c_can: Fix berr reporting
      can: c_can: Always update error stats
      can: c_can: Simplify buffer reenabling
      can: c_can: Avoid status register update for D_CAN
      can: c_can: Get rid of pointless interrupts
      can: c_can: Disable rx split as workaround
      can: c_can: Work around C_CAN RX wreckage
      can: c_can: Cleanup irq enable/disable
      can: c_can: Cleanup c_can_read_msg_object()
      can: c_can: Cleanup setup of receive buffers
      can: c_can: Cleanup c_can_inval_msg_object()
      can: c_can: Cleanup c_can_msg_obj_put/get()
      can: c_can: Cleanup c_can_write_msg_object()
      can: c_can: Use proper u32 variables in c_can_write_msg_object()
      can: c_can: Remove tx locking
      can: c_can: Speed up tx buffer invalidation

Wolfgang Grandegger (1):
      can: c_can_pci: enable PCI bus master only for MSI

Wolfram Sang (1):
      can: c_can: use proper type for 'instance'

 drivers/net/can/c_can/Kconfig          |   7 +
 drivers/net/can/c_can/c_can.c          | 660 +++++++++++++++------------------
 drivers/net/can/c_can/c_can.h          |  23 +-
 drivers/net/can/c_can/c_can_pci.c      |   9 +-
 drivers/net/can/c_can/c_can_platform.c |   2 +-
 drivers/net/can/dev.c                  |   2 +-
 drivers/net/can/sja1000/sja1000_isa.c  |  16 +-
 drivers/net/can/slcan.c                |   6 +-
 8 files changed, 343 insertions(+), 382 deletions(-)

