From: Joe Perches <joe@perches.com>
Subject: [PATCH 30/49] drivers/net/sfc: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:54 -0700
Message-ID: <70ba2984e2d82d5f7dd6733f8466e3b2a8774747.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4140 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816Ab0KEDI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 23:08:57 -0400
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sfc/filter.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 52cb608..44500b5 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -428,10 +428,9 @@ int efx_probe_filters(struct efx_nic *efx)
 					     GFP_KERNEL);
 		if (!table->used_bitmap)
 			goto fail;
-		table->spec = vmalloc(table->size * sizeof(*table->spec));
+		table->spec = vzalloc(table->size * sizeof(*table->spec));
 		if (!table->spec)
 			goto fail;
-		memset(table->spec, 0, table->size * sizeof(*table->spec));
 	}
 
 	return 0;
-- 
1.7.3.1.g432b3.dirty

