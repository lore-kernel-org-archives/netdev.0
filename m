From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 03/10] netvsc: don't print pointer value in error message
Date: Wed, 26 Jul 2017 16:40:22 -0700
Message-ID: <20170726234029.7342-4-sthemmin@microsoft.com>
References: <20170726234029.7342-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34040 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdGZXks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 19:40:48 -0400
Received: by mail-pg0-f48.google.com with SMTP id 123so90267067pgj.1
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 16:40:48 -0700 (PDT)
In-Reply-To: <20170726234029.7342-1-sthemmin@microsoft.com>
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
