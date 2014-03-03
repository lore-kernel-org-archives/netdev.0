From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-03-03
Date: Mon,  3 Mar 2014 14:54:27 +0100
Message-ID: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43407 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881AbaCCNyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 08:54:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of 8 patches. Oliver Hartkopp contributes a patch which
removes the CAN FD compatibility for CAN 2.0 sockets, as it turns out that this
compatibility has some conceptual cornercases. The remaining 7 patches are by
me, they address a problem in the flexcan driver. When shutting down the
interface ("ifconfig can0 down") under heavy network load the whole system will
hang. This series reworks the actual sequence in close() and the transition
from and to the low power modes of the CAN controller.

regards,
Marc
---

The following changes since commit 635d61a3735e05c8da72740006670f819e5b6a5f:

  USB AX88179/178A: Support D-Link DUB-1312 (2014-03-02 20:29:30 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.14-20140303

for you to fetch changes up to 821047c4055cca833c4674f172a9d73003563eb6:

  can: remove CAN FD compatibility for CAN 2.0 sockets (2014-03-03 14:29:52 +0100)

----------------------------------------------------------------
linux-can-fixes-for-3.14-20140303

----------------------------------------------------------------
Marc Kleine-Budde (7):
      can: flexcan: fix shutdown: first disable chip, then all interrupts
      can: flexcan: flexcan_open(): fix error path if flexcan_chip_start() fails
      can: flexcan: fix transition from and to low power mode in chip_{en,dis}able
      can: flexcan: factor out transceiver {en,dis}able into seperate functions
      can: flexcan: fix transition from and to freeze mode in chip_{,un}freeze
      can: flexcan: flexcan_remove(): add missing netif_napi_del()
      can: flexcan: factor out soft reset into seperate funtion

Oliver Hartkopp (1):
      can: remove CAN FD compatibility for CAN 2.0 sockets

 Documentation/networking/can.txt |   6 --
 drivers/net/can/flexcan.c        | 172 +++++++++++++++++++++++++++++----------
 net/can/raw.c                    |  26 ++----
 3 files changed, 136 insertions(+), 68 deletions(-)
