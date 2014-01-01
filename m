From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 0/5] alx: add statistics
Date: Thu,  2 Jan 2014 00:40:23 +0100
Message-ID: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:37475 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686AbaAAXnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 18:43:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the alx driver doesn't support statistics [1,2]. The
original alx driver [3] that Johannes Berg modified provided
statistics. This patch is an adaptation of the statistics code from
the original driver to the alx driver included in the kernel.

The original driver has a different version of the
__alx_update_hw_stats function (patch 3). I rewrote it because I
thought the code was not as clear, and it could be cause bugs if the
stats structure was modified. Here is the original version:

void __alx_update_hw_stats(struct alx_hw *hw)
{
	u16 reg;
	u32 data;
	unsigned long *p;

	/* RX stats */
	reg = ALX_RX_STATS_BIN;
	p = &hw->stats.rx_ok;
	while (reg <=  ALX_RX_STATS_END) {
		data = alx_read_mem32(hw, reg);
		*p++ += data;
		reg += 4;
	}

	/* TX stats */
	reg = ALX_TX_STATS_BIN;
	p = &hw->stats.tx_ok;
	while (reg <= ALX_TX_STATS_END) {
		data = alx_read_mem32(hw, reg);
		*p++ += data;
		reg += 4;
	}
}

If you prefer this version, I can resend the patches with this code
instead of the one in patch 3.
Patch 2 removes the constants used in the original version of the
update function and adds the ones necessary for patch 3, so it shouldn't
be used with the original version (above).

[1] https://bugzilla.kernel.org/show_bug.cgi?id=63401
[2] http://www.spinics.net/lists/netdev/msg245544.html
[3] https://github.com/mcgrof/alx

Sabrina Dubroca (5):
  alx: add a hardware stats structure
  alx: add constants for the stats fields
  alx: add stats update function
  alx: add alx_get_stats operation
  alx: add stats to ethtool

 drivers/net/ethernet/atheros/alx/alx.h     |  3 +
 drivers/net/ethernet/atheros/alx/ethtool.c | 95 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/atheros/alx/hw.c      | 58 ++++++++++++++++++
 drivers/net/ethernet/atheros/alx/hw.h      | 61 +++++++++++++++++++
 drivers/net/ethernet/atheros/alx/main.c    | 44 ++++++++++++++
 drivers/net/ethernet/atheros/alx/reg.h     | 52 ++++++++++++++--
 6 files changed, 309 insertions(+), 4 deletions(-)

-- 
1.8.5.2
