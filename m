From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: linux-next: manual merge of the net tree with the
 net-current tree
Date: Tue, 8 Mar 2011 11:44:33 +0200
Message-ID: <1299577473.17233.41.camel@lb-tlvb-dmitry>
References: <20110308140957.8a894312.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110308140957.8a894312.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-03-07 at 19:09 -0800, Stephen Rothwell wrote:
> Just overlapping additions (I think).  I have fixed it up (see below) and
> can carry the fix as necessary.
You are correct it's just an addition and it does not really matter
where to do this. But the merge pushed new code in the middle
of MAC configuration between MAC and multicast list.
It's clearer to put it at the end of MAC/ML/UL block:
---
 drivers/net/bnx2x/bnx2x_cmn.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index b01b622..9e37675 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1498,6 +1498,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Clear UC lists configuration */
 	bnx2x_invalidate_uc_list(bp);
 
+	if (bp->pending_max) {
+		bnx2x_update_max_mf_config(bp, bp->pending_max);
+		bp->pending_max = 0;
+	}
+
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp, load_mode);
 
-- 
1.7.2.2
