From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-04-01
Date: Tue,  1 Apr 2014 23:42:14 +0200
Message-ID: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of 16 patches for the 3.15 release cycle.

Bjorn Van Tilt contributes a patch which fixes a memory leak in usb_8dev's
usb_8dev_start_xmit()s error path. A patch by Robert Schwebel fixes a typo in
the can documentation. The remaining patches all target the c_can driver. Two
of them are by me; they add a missing netif_napi_del() and return value
checking. Thomas Gleixner contributes 12 patches, which address several
shortcomings in the driver like hardware initialisation, concurrency, message
ordering and poor performance.

regards,
Marc

---

The following changes since commit 17e84a9253467552fb06f99c009bb0bc1d7bfd39:

  at86rf230: mask irq's before deregister device (2014-03-31 16:43:14 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.15-20140401

for you to fetch changes up to b1d8e431bd5639c03ff99d08fd2d5d621969bdc5:

  can: c_can: Avoid led toggling for every packet. (2014-04-01 11:55:02 +0200)

----------------------------------------------------------------
linux-can-fixes-for-3.15-20140401

----------------------------------------------------------------
Bjorn Van Tilt (1):
      can: usb_8dev: Fix memory leak in usb_8dev_start_xmit

Marc Kleine-Budde (2):
      can: c_can: free_c_can_dev(): add missing netif_napi_del()
      can: c_can: check return value to users of c_can_set_bittiming()

Robert Schwebel (1):
      can: Documentation: fix parameter name "sample-point"

Thomas Gleixner (12):
      can: c_can: Wait for CONTROL_INIT to be cleared
      can: c_can: Fix hardware raminit function
      can: c_can: Make it SMP safe
      can: c_can: Fix buffer ordering
      can: c_can: Fix the lost message handling
      can: c_can: Remove EOB exit
      can: c_can: Provide protection in the xmit path
      can: c_can: Make the code readable
      can: c_can: Reduce register access
      can: c_can: Store dlc private
      can: c_can: Simplify TX interrupt cleanup
      can: c_can: Avoid led toggling for every packet.

 Documentation/networking/can.txt       |   2 +-
 drivers/net/can/c_can/c_can.c          | 348 +++++++++++++++++++--------------
 drivers/net/can/c_can/c_can.h          |  29 +++
 drivers/net/can/c_can/c_can_platform.c |  47 ++++-
 drivers/net/can/usb/usb_8dev.c         |   2 +-
 5 files changed, 266 insertions(+), 162 deletions(-)


