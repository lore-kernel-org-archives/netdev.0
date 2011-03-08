From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 8 Mar 2011 14:09:57 +1100
Message-ID: <20110308140957.8a894312.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/bnx2x/bnx2x_cmn.c between commit
e3835b99333eb3ac7222f6fc0af5cae46074ac49 ("bnx2x: (NPAR) prevent HW
access in D3 state") from the net-current tree and commit
6e30dd4e3935ddb4e7dd27d5be7a6e5504e64a27 (bnx2x: Proper
netdev->ndo_set_rx_mode() implementation"") from the net tree.

Just overlapping additions (I think).  I have fixed it up (see below) and
can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/bnx2x/bnx2x_cmn.c
index a71b329,b01b622..0000000
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@@ -1481,11 -1489,15 +1506,20 @@@ int bnx2x_nic_load(struct bnx2x *bp, in
  
  	bnx2x_set_eth_mac(bp, 1);
  
 +	if (bp->pending_max) {
 +		bnx2x_update_max_mf_config(bp, bp->pending_max);
 +		bp->pending_max = 0;
 +	}
 +
+ 	/* Clear MC configuration */
+ 	if (CHIP_IS_E1(bp))
+ 		bnx2x_invalidate_e1_mc_list(bp);
+ 	else
+ 		bnx2x_invalidate_e1h_mc_list(bp);
+ 
+ 	/* Clear UC lists configuration */
+ 	bnx2x_invalidate_uc_list(bp);
+ 
  	if (bp->port.pmf)
  		bnx2x_initial_phy_init(bp, load_mode);
  
