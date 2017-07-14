From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net 0/2] Fragmented SKB corrections
Date: Fri, 14 Jul 2017 16:12:08 -0700
Message-ID: <20170714231210.12967-1-opendmb@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org, Doug Berger <opendmb@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two issues were observed in a review of the bcmgenet driver support for
fragmented SKBs which are addressed by this patch set.

The first addresses a problem that could occur if the driver is not able
to DMA map a fragment of the SKB.  This would be a highly unusual event
but it would leave the hardware descriptors in an invalid state which
should be prevented.

The second is a hazard that could occur if the driver is able to reclaim
the first control block of a fragmented SKB before all of its fragments
have completed processing by the hardware.  In this case the SKB could
be freed leading to reuse of memory that is still in use by hardware.

Doug Berger (2):
  net: bcmgenet: Fix unmapping of fragments in bcmgenet_xmit()
  net: bcmgenet: Free skb after last Tx frag

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 299 +++++++++++++------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   2 +
 2 files changed, 152 insertions(+), 149 deletions(-)

-- 
2.13.0
