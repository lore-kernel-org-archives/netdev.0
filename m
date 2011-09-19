From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 19 Sep 2011 14:51:03 +1000
Message-ID: <20110919145103.6c3e73edf51599eaa703294a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yaniv Rosner <yanivr@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c between commit
c482e6c06461 ("bnx2x: Fix ETS bandwidth") from Linus' tree and commit
94f05b0f60de ("bnx2x: Coalesce pr_cont uses and fix DP typos") from the
net tree.

The former removes the code cleaned up by the latter, so I used the
former (see below).
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index ba15bdc,8e9b87b..0000000
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@@ -852,20 -852,26 +852,20 @@@ static int bnx2x_ets_e3b0_get_total_bw
  	/* Calculate total BW requested */
  	for (cos_idx = 0; cos_idx < ets_params->num_of_cos; cos_idx++) {
  		if (bnx2x_cos_state_bw == ets_params->cos[cos_idx].state) {
 -
 -			if (0 == ets_params->cos[cos_idx].params.bw_params.bw) {
 -				DP(NETIF_MSG_LINK,
 -				   "bnx2x_ets_E3B0_config BW was set to 0\n");
 -			return -EINVAL;
 +			*total_bw +=
 +				ets_params->cos[cos_idx].params.bw_params.bw;
  		}
 -		*total_bw +=
 -		    ets_params->cos[cos_idx].params.bw_params.bw;
 -	    }
  	}
  
 -	/*Check taotl BW is valid */
 +	/* Check total BW is valid */
  	if ((100 != *total_bw) || (0 == *total_bw)) {
  		if (0 == *total_bw) {
- 			DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config toatl BW"
- 					   "shouldn't be 0\n");
+ 			DP(NETIF_MSG_LINK,
+ 			   "bnx2x_ets_E3B0_config toatl BW shouldn't be 0\n");
  			return -EINVAL;
  		}
- 		DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config toatl BW should be"
- 				   "100\n");
+ 		DP(NETIF_MSG_LINK,
+ 		   "bnx2x_ets_E3B0_config toatl BW should be 100\n");
  		/**
  		*   We can handle a case whre the BW isn't 100 this can happen
  		*   if the TC are joined.
