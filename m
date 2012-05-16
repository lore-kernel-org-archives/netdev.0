From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 2/2] 6lowpan: fix hop limit compression
Date: Wed, 16 May 2012 11:27:28 +0400
Message-ID: <1337153248-5779-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1337153248-5779-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:49121 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759381Ab2EPH2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 03:28:43 -0400
Received: by wgbdr13 with SMTP id dr13so403573wgb.1
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 00:28:42 -0700 (PDT)
In-Reply-To: <1337153248-5779-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing pointer shift for the 'default' case.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index c2bbf01..9a5afaa 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -497,6 +497,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 		break;
 	default:
 		*hc06_ptr = hdr->hop_limit;
+		hc06_ptr += 1;
 		break;
 	}
 
-- 
1.7.2.3
