From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 3/5] jme: Prevent possible read re-order error
Date: Tue, 19 Oct 2010 08:10:42 +0800
Message-ID: <1287447044-24471-3-git-send-email-cooldavid@cooldavid.org>
References: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:49740 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757434Ab0JSAU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 20:20:58 -0400
In-Reply-To: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Adding read memory barrier in between flag reading and data reading of
receive descriptors. This prevents the data being read before hardware
complete writing informations.

Reported-by: Stefan Hajnoczi <stefanha@gmail.com>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 0ea0da3..095f899 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -989,6 +989,7 @@ jme_process_receive(struct jme_adapter *jme, int limit)
 			goto out;
 		--limit;
 
+		rmb();
 		desccnt = rxdesc->descwb.desccnt & RXWBDCNT_DCNT;
 
 		if (unlikely(desccnt > 1 ||
-- 
1.7.2.2

