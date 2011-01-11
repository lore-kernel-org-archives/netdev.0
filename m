From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH v2 0/3] can: at91_can: fix for errata 50.2.6.3 & 50.3.5.3
Date: Tue, 11 Jan 2011 14:21:22 +0100
Message-ID: <1294752085-30151-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
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

as promised I've implemented the proposed workaround for the errata
50.2.6.3 & 50.3.5.3:
"Contents of Mailbox 0 can be sent Even if Mailbox is Disabled"

This means under high bus load it can happen that the mailbox 0 is send
to the bus. And it does happen, even with the mainline driver where
Mailbox 0 is a receive mailbox. The errata proposes not to use mailbox 0
and load it with an unused can_id that will not disturb the bus.

The first patch cleans up the driver without any functional changes, so
that the mailbox 0 can be disabled in the second patch. The third patch
adds a sysfs parameter to the driver, so that the identifier of mailbox 0
can configured.

This series applies to net-2.6/master. It has been tested on a ronetix pm9263
board against a PCI-SJA1000 card with the canfdtest utility.

changes since v1:
- Documentation/ABI/testing/sysfs-platform-at91 (as suggested by Wolfram Sang)
- fixed typo in PATCH 3's commit message

regards, Marc

---

The following changes since commit b11a25aaeccc29d5090d1ce9776af20e3ee99ab9:

  qlcnic: change module parameter permissions (2011-01-10 13:34:55 -0800)

are available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git can/at91_can-for-net-2.6

Marc Kleine-Budde (3):
      can: at91_can: clean up usage of AT91_MB_RX_FIRST and AT91_MB_RX_NUM
      can: at91_can: don't use mailbox 0
      can: at91_can: make can_id of mailbox 0 configurable

 Documentation/ABI/testing/sysfs-platform-at91 |   25 +++++
 drivers/net/can/at91_can.c                    |  138 ++++++++++++++++++++-----
 2 files changed, 137 insertions(+), 26 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-platform-at91
