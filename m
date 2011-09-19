From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 19 Sep 2011 19:04:38 +0300
Message-ID: <1316448278.12042.3.camel@lb-tlvb-dmitry>
References: <20110919145103.6c3e73edf51599eaa703294a@canb.auug.org.au>
 <1316415318.26848.4.camel@lb-tlvb-dmitry>
 <1316447682.6276.5.camel@Joe-Laptop>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Stephen Rothwell" <sfr@canb.auug.org.au>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316447682.6276.5.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-09-19 at 08:54 -0700, Joe Perches wrote:
> On Mon, 2011-09-19 at 09:55 +0300, Dmitry Kravkov wrote:
> > On Sun, 2011-09-18 at 21:51 -0700, Stephen Rothwell wrote:
> > > Today's linux-next merge of the net tree got a conflict in
> > > drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c between commit
> > > c482e6c06461 ("bnx2x: Fix ETS bandwidth") from Linus' tree and commit
> > > 94f05b0f60de ("bnx2x: Coalesce pr_cont uses and fix DP typos") from the
> > > net tree.
> []
> > Can you use this one instead?
> > Contains spell fixes and some formatting.
> 
> Multiple line format strings lines are bad style and error prone.
> You introduce broken spacing after string coalescing.
> 

Contains spell fixes and some formatting

v2: fix broken spacing

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
Joe, Thanks for noticing that
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   30 ++++++++--------------
 1 files changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 8e9b87b..5a9444a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -850,32 +850,24 @@ static int bnx2x_ets_e3b0_get_total_bw(
 
 	*total_bw = 0 ;
 	/* Calculate total BW requested */
-	for (cos_idx = 0; cos_idx < ets_params->num_of_cos; cos_idx++) {
-		if (bnx2x_cos_state_bw == ets_params->cos[cos_idx].state) {
+	for (cos_idx = 0; cos_idx < ets_params->num_of_cos; cos_idx++)
+		if (bnx2x_cos_state_bw == ets_params->cos[cos_idx].state)
+			*total_bw +=
+				ets_params->cos[cos_idx].params.bw_params.bw;
 
-			if (0 == ets_params->cos[cos_idx].params.bw_params.bw) {
-				DP(NETIF_MSG_LINK,
-				   "bnx2x_ets_E3B0_config BW was set to 0\n");
-			return -EINVAL;
-		}
-		*total_bw +=
-		    ets_params->cos[cos_idx].params.bw_params.bw;
-	    }
-	}
-
-	/*Check taotl BW is valid */
+	/* Check total BW is valid */
 	if ((100 != *total_bw) || (0 == *total_bw)) {
 		if (0 == *total_bw) {
 			DP(NETIF_MSG_LINK,
-			   "bnx2x_ets_E3B0_config toatl BW shouldn't be 0\n");
+			  "bnx2x_ets_E3B0_config total BW shouldn't be 0\n");
 			return -EINVAL;
 		}
 		DP(NETIF_MSG_LINK,
-		   "bnx2x_ets_E3B0_config toatl BW should be 100\n");
-		/**
-		*   We can handle a case whre the BW isn't 100 this can happen
-		*   if the TC are joined.
-		*/
+		   "bnx2x_ets_E3B0_config total BW should be 100\n");
+		/*
+		 * We can handle a case where the BW isn't 100 this can happen
+		 * if the TC are joined.
+		 */
 	}
 	return 0;
 }
-- 
1.7.2.2
