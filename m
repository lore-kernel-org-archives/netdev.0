From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH V2 0/7] can: mcp251x: fix and optimize driver
Date: Fri, 15 Oct 2010 12:49:15 +0200
Message-ID: <1287139762-23356-1-git-send-email-mkl@pengutronix.de>
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
in order to optimise the driver.

This series has been tested with a mcp2515 on i.MX35.

Changes since V1:
- Fix broken encoding in S-o-b

Please review, test and consider to apply.

regards, Marc

---

The following changes since commit cd2638a86c7b90e77ce623c09de2a26177f2a5c1:
  Carolyn Wyborny (1):
        igb: add check for fiber/serdes devices to igb_set_spd_dplx;

are available in the git repository at:

  git://git.pengutronix.de/git/mkl/linux-2.6.git can/mcp251x-for-net-next

Marc Kleine-Budde (4):
      can: mcp251x: fix NOHZ local_softirq_pending 08 warning
      can: mcp251x: write intf only when needed
      can: mcp251x: define helper functions mcp251x_is_2510, mcp251x_is_2515
      can: mcp251x: optimize 2515, rx int gets cleared automatically

Sascha Hauer (3):
      can: mcp251x: increase rx_errors on overflow, not only rx_over_errors
      can: mcp251x: allow to read two registers in one spi transfer
      can: mcp251x: read-modify-write eflag only when needed

 drivers/net/can/mcp251x.c |   77 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 60 insertions(+), 17 deletions(-)
