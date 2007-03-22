From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.21] iw_cxgb3: Handle build_phys_page_list()
	failure in iwch_reregister_phys_mem().
Date: Thu, 22 Mar 2007 10:38:20 -0500
Message-ID: <1174577900.16862.27.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	General@lists.openfabrics.org, Adrian Bunk <bunk@stusta.de>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Handle build_phys_page_list() failure in iwch_reregister_phys_mem().

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_provider.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index f2774ae..24e0df0 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -545,11 +545,14 @@ static int iwch_reregister_phys_mem(stru
 		php = to_iwch_pd(pd);
 	if (mr_rereg_mask & IB_MR_REREG_ACCESS)
 		mh.attr.perms = iwch_ib_to_tpt_access(acc);
-	if (mr_rereg_mask & IB_MR_REREG_TRANS)
+	if (mr_rereg_mask & IB_MR_REREG_TRANS) {
 		ret = build_phys_page_list(buffer_list, num_phys_buf,
 					   iova_start,
 					   &total_size, &npages,
 					   &shift, &page_list);
+		if (ret)
+			return ret;
+	}
 
 	ret = iwch_reregister_mem(rhp, php, &mh, shift, page_list, npages);
 	kfree(page_list);
