From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH V3 0/8] can: mcp251x: fix and optimize driver
Date: Mon, 18 Oct 2010 15:31:06 +0200
Message-ID: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
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

Moin,

this series of patches improves the mcp251x driver. It first fixes the
local_softirq_pending problem. Then the amount of SPI transfers is reduced
in order to optimise the driver. A further patch cleans up the chip model
selection.

This series has been tested with a mcp2515 on i.MX35.

Please review, test and consider to apply.

regards, Marc

--

The following changes since commit 724829b3ad8e8aeb0aec46de383d35bfa1ad3875:
  David S. Miller (1):
        tipc: Kill tipc_get_mode() completely.

are available in the git repository at:

  git://git.pengutronix.de/git/mkl/linux-2.6.git can/mcp251x-for-net-next

Marc Kleine-Budde (5):
      can: mcp251x: fix NOHZ local_softirq_pending 08 warning
      can: mcp251x: write intf only when needed
      can: mcp251x: Don't use pdata->model for chip selection anymore
      can: mcp251x: define helper functions mcp251x_is_2510, mcp251x_is_2515
      can: mcp251x: optimize 2515, rx int gets cleared automatically

Sascha Hauer (3):
      can: mcp251x: increase rx_errors on overflow, not only rx_over_errors
      can: mcp251x: allow to read two registers in one spi transfer
      can: mcp251x: read-modify-write eflag only when needed

 drivers/net/can/mcp251x.c            |   95 +++++++++++++++++++++++++---------
 include/linux/can/platform/mcp251x.h |    4 --
 2 files changed, 70 insertions(+), 29 deletions(-)
