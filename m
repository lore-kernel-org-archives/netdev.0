From: Noam Camus <noamc@ezchip.com>
Subject: [v1 0/6] *** nps_enet fixups ***
Date: Mon, 17 Aug 2015 08:58:33 +0300
Message-ID: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>

This patch set is a bunch of fixes to make nps_enet work correctly with
all platforms, i.e. real device, emulation system, and simulation system.
The main trigger for this patch set was that in our emulation system
the TX end interrupt is "edge-sensitive" and therefore we cannot use the
cause register since it is not sticky.
Also:
TX is handled during HW interrupt context and not NAPI job.
race with TX done was fixed.
added acknowledge for TX when device is "level sensitive".
enable drop of control frames which is not needed for regular usage.

So most of this patch set is about TX handling, which is now more complete.

Noam Camus (6):
  NET: nps_enet: replace use of cause register
  NET: nps_enet: reduce processing latency.
  NET: nps_enet: TX done race condition
  NET: nps_enet: drop control frames
  NET: nps_enet: TX done acknowledge.
  NET: nps_enet: minor namespace cleanup

 drivers/net/ethernet/ezchip/nps_enet.c |   44 +++++++++++++++++--------------
 drivers/net/ethernet/ezchip/nps_enet.h |   20 --------------
 2 files changed, 24 insertions(+), 40 deletions(-)
