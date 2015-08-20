From: Noam Camus <noamc@ezchip.com>
Subject: [v2 0/5] *** nps_enet fixups ***
Date: Thu, 20 Aug 2015 08:00:00 +0300
Message-ID: <1440046805-24459-1-git-send-email-noamc@ezchip.com>
References: <20150817.103607.1737876155019074073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0074.outbound.protection.outlook.com ([157.55.234.74]:30892
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750879AbbHTFFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 01:05:22 -0400
In-Reply-To: <20150817.103607.1737876155019074073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noam Camus <noamc@ezchip.com>

Change v2
TX done is handled back with NAPI poll.

Change v1
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

Noam Camus (5):
  NET: nps_enet: replace use of cause register
  NET: nps_enet: TX done race condition
  NET: nps_enet: drop control frames
  NET: nps_enet: TX done acknowledge.
  NET: nps_enet: minor namespace cleanup

 drivers/net/ethernet/ezchip/nps_enet.c |   37 ++++++++++++++++---------------
 drivers/net/ethernet/ezchip/nps_enet.h |   20 -----------------
 2 files changed, 19 insertions(+), 38 deletions(-)
