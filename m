From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v3 3/7] netvsc: don't print pointer value in error message
Date: Fri, 28 Jul 2017 08:59:43 -0700
Message-ID: <20170728155947.10062-4-sthemmin@microsoft.com>
References: <20170728155947.10062-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33702 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdG1P7x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:59:53 -0400
Received: by mail-pf0-f177.google.com with SMTP id d67so29547556pfc.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 08:59:53 -0700 (PDT)
In-Reply-To: <20170728155947.10062-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using %p to print pointer to packet meta-data doesn't give any
good info, and exposes kernel memory offsets.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 94c00acac58a..f0c15e782ce0 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -805,8 +805,10 @@ static inline int netvsc_send_pkt(
 			ret = -ENOSPC;
 		}
 	} else {
-		netdev_err(ndev, "Unable to send packet %p ret %d\n",
-			   packet, ret);
+		netdev_err(ndev,
+			   "Unable to send packet pages %u len %u, ret %d\n",
+			   packet->page_buf_cnt, packet->total_data_buflen,
+			   ret);
 	}
 
 	return ret;
-- 
2.11.0
