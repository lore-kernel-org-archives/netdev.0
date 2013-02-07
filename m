From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2-net-3.8 3/3] bnx2x: set gso_type
Date: Thu, 7 Feb 2013 15:13:22 +0200
Message-ID: <b9413cd3577c7b544cd522a6eb8ae6b037b20da6.1360236441.git.mst@redhat.com>
References: <cover.1360236441.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, e1000-devel@lists.sourceforge.net,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <cover.1360236441.git.mst@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In LRO mode, bnx2x set gso_size but not gso type.
This leads to crashes in macvtap.
Commit cbf1de72324a8105ddcc3d9ce9acbc613faea17e
queued for 3.9 includes a more complete fix.
This is a minimal patch to avoid the crash, for 3.8.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f771ddf..a5edac8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -504,13 +504,11 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp,
 					tpa_info->parsing_flags, len_on_bd);
 
-		/* set for GRO */
-		if (fp->mode == TPA_MODE_GRO)
-			skb_shinfo(skb)->gso_type =
-			    (GET_FLAG(tpa_info->parsing_flags,
-				      PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
-						PRS_FLAG_OVERETH_IPV6) ?
-				SKB_GSO_TCPV6 : SKB_GSO_TCPV4;
+		skb_shinfo(skb)->gso_type =
+			(GET_FLAG(tpa_info->parsing_flags,
+				  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
+			 PRS_FLAG_OVERETH_IPV6) ?
+			SKB_GSO_TCPV6 : SKB_GSO_TCPV4;
 	}
 
 
-- 
MST

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
