From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 07/10] mvneta: Replace put_page(virt_to_head_page(ptr)) w/
 skb_free_frag
Date: Wed, 06 May 2015 21:12:14 -0700
Message-ID: <20150507041214.1873.71461.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40411 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbbEGEMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 00:12:15 -0400
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/marvell/mvneta.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9cff06..ecce8261ce3b 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1359,7 +1359,7 @@ static void *mvneta_frag_alloc(const struct mvneta_port *pp)
 static void mvneta_frag_free(const struct mvneta_port *pp, void *data)
 {
 	if (likely(pp->frag_size <= PAGE_SIZE))
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 	else
 		kfree(data);
 }
