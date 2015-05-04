From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/6] netcp: Replace
 put_page(virt_to_head_page(ptr)) w/ skb_free_frag
Date: Mon, 04 May 2015 16:14:53 -0700
Message-ID: <20150504231453.1538.70827.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net
To: linux-mm@kvack.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39889 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbbEDXOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 19:14:55 -0400
In-Reply-To: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/ti/netcp_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 43efc3a0cda5..0a28c07361cf 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -537,7 +537,7 @@ int netcp_unregister_rxhook(struct netcp_intf *netcp_priv, int order,
 static void netcp_frag_free(bool is_frag, void *ptr)
 {
 	if (is_frag)
-		put_page(virt_to_head_page(ptr));
+		skb_free_frag(ptr);
 	else
 		kfree(ptr);
 }
