From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 00/10] can: at91: bugfixes and improvements
Date: Thu, 21 Oct 2010 13:01:12 +0200
Message-ID: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

this series of patches fixes three bugs (CAN_CTRLMODE_3_SAMPLES,
extended frames, use-after-free), a compiler warning (uninit'ed variable) and
a section mismatch. Further it add the implementation of the
do_get_berr_counter callback, the bittiming setting is now done in chip_start.
As requested by Russell King the driver uses __raw_readl instead of readl.

The last two patches do some cleanups, they convert dev_<level> printing
to netdev_<level> and add the KBUILD_MODNAME to the bit timing constant
to identify the driver.

Please review and consider to apply,
Marc

---

The following changes since commit 27b75c95f10d249574d9c4cb9dab878107faede8:
  Eric Dumazet (1):
        net: avoid RCU for NOCACHE dst

are available in the git repository at:

  git://git.pengutronix.de/git/mkl/linux-2.6.git can/at91_can-for-net-next

Marc Kleine-Budde (10):
      can: at91_can: use correct bit to enable CAN_CTRLMODE_3_SAMPLES
      can: at91_can: fix reception of extended frames
      can: at91_can: fix use after free of priv
      can: at91_can: fix compiler warning in at91_irq_err_state
      can: at91_can: fix section mismatch warning
      can: at91_can: implement and use at91_get_berr_counter
      can: at91_can: set bittiming in chip_start
      can: at91_can: convert readl, writel their __raw pendants
      can: at91_can: convert dev_<level> printing to netdev_<level>
      can: at91_can: add KBUILD_MODNAME to bittiming constant

 drivers/net/can/at91_can.c |   95 ++++++++++++++++++++++++++------------------
 1 files changed, 56 insertions(+), 39 deletions(-)
