From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH] kcm: fix variable type
Date: Fri, 11 Mar 2016 07:51:15 +0100
Message-ID: <1457679075-22094-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.w1.samsung.com ([210.118.77.14]:43120 "EHLO
	mailout4.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbcCKGvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 01:51:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function skb_splice_bits can return negative values, its result should
be assigned to signed variable to allow correct error checking.

The problem has been detected using patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 net/kcm/kcmsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 40662d73..0b68ba7 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1483,7 +1483,7 @@ static ssize_t kcm_splice_read(struct socket *sock, loff_t *ppos,
 	long timeo;
 	struct kcm_rx_msg *rxm;
 	int err = 0;
-	size_t copied;
+	ssize_t copied;
 	struct sk_buff *skb;
 
 	/* Only support splice for SOCKSEQPACKET */
-- 
1.9.1
