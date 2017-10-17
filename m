From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH] net/mqprio: Fix build error due to non-exported
 symbol
Date: Mon, 16 Oct 2017 17:05:29 -0700
Message-ID: <20171017000518.3786.93703.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:50384 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753504AbdJQAFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 20:05:32 -0400
Received: by mail-pf0-f194.google.com with SMTP id b6so3996pfh.7
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 17:05:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

I overlooked the fact that netdev_txq_to_tc was not an exported symbol. To
fix that I am providing the export for the symbol in order to avoid
breaking builds where mqprio is not built into the kernel.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index fb766d906148..0aa255f3a866 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2008,6 +2008,7 @@ int netdev_txq_to_tc(struct net_device *dev, unsigned int txq)
 
 	return 0;
 }
+EXPORT_SYMBOL(netdev_txq_to_tc);
 
 #ifdef CONFIG_XPS
 static DEFINE_MUTEX(xps_map_mutex);
