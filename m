From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 0/4] net-next: mediatek: IRQ cleanups, fixes and grouping
Date: Wed, 29 Jun 2016 13:38:07 +0200
Message-ID: <1467200291-60106-1-git-send-email-john@phrozen.org>
Cc: Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series contains 2 small code cleanups that are leftovers from the
MIPS support. There is also a small fix that adds proper locking to the
code accessing the IRQ registers. Without this fix we saw deadlocks caused
by the last patch of the series, which adds IRQ grouping. The grouping
feature allows us to use different IRQs for TX and RX. By doing so we can
use affinity to let the SoC handle the IRQs on different cores.

This series depends on a previous series currently sitting in net.git
starting with
	commit 562c5a70400c ("net: mediatek: only wake the queue if it is stopped")
up to
	commit 82c6544dddc6 ("net: mediatek: remove superfluous queue wake up call")


John Crispin (4):
  net-next: mediatek: remove superfluous register reads
  net-next: mediatek: don't use intermediate variables to store IRQ
    masks
  net-next: mediatek: add IRQ locking
  net-next: mediatek: add support for IRQ grouping

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |  174 +++++++++++++++++----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |   16 ++-
 2 files changed, 122 insertions(+), 68 deletions(-)

-- 
1.7.10.4
