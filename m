From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 6/7] 6lowpan: fix tag variable size
Date: Wed, 11 Jul 2012 11:22:47 +0400
Message-ID: <1341991368-11800-7-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Tony Cheneau <tony.cheneau@amnesiak.org>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56445 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756420Ab2GKH1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:27:06 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so656595wey.19
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:27:06 -0700 (PDT)
In-Reply-To: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function lowpan_alloc_new_frame() takes u8 tag as an argument. However,
its only caller, lowpan_process_data() passes down a u16. Hence,
the tag value can get corrupted. This prevent 6lowpan fragment reassembly of a
message when the fragment tag value is over 256.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Tony Cheneau <tony.cheneau@amnesiak.org>
---
 net/ieee802154/6lowpan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index ae3f4eb..2e790fb 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -646,7 +646,7 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
 }
 
 static struct lowpan_fragment *
-lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u8 tag)
+lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u16 tag)
 {
 	struct lowpan_fragment *frame;
 
-- 
1.7.2.3
