From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 10/10] bnx2x,
 tg3: Replace put_page(virt_to_head_page()) with skb_free_frag()
Date: Wed, 06 May 2015 21:12:31 -0700
Message-ID: <20150507041231.1873.76848.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbbEGEMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 00:12:32 -0400
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/tg3.c             |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a8bb8f664d3d..b10d1744e5ae 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -662,7 +662,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 static void bnx2x_frag_free(const struct bnx2x_fastpath *fp, void *data)
 {
 	if (fp->rx_frag_size)
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 	else
 		kfree(data);
 }
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 069952fa5d64..73c934cf6c61 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6618,7 +6618,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 static void tg3_frag_free(bool is_frag, void *data)
 {
 	if (is_frag)
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 	else
 		kfree(data);
 }
