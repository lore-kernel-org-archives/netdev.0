From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v3 2/3] 6lowpan: fix hop limit compression
Date: Mon, 25 Jun 2012 17:49:02 +0400
Message-ID: <1340632143-27794-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1340632143-27794-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Tony Cheneau <tony.cheneau+zigbeedev@amnesiak.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49406 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756717Ab2FYNwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 09:52:20 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so3150469bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 06:52:20 -0700 (PDT)
In-Reply-To: <1340632143-27794-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing pointer shift for the 'default' case.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Tony Cheneau <tony.cheneau+zigbeedev@amnesiak.org>
---
 net/ieee802154/6lowpan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 5c7bcf9..b45e229 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -492,6 +492,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 		break;
 	default:
 		*hc06_ptr = hdr->hop_limit;
+		hc06_ptr += 1;
 		break;
 	}
 
-- 
1.7.2.3
