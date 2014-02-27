From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] neigh: directly goto out after setting nud_state
 to NUD_FAILED
Date: Thu, 27 Feb 2014 17:03:03 +0800
Message-ID: <530EFF47.6090001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:22728 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751688AbaB0JEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 04:04:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Because those following if conditions will not be matched.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/core/neighbour.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b9e9e0d..026bfd1 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -945,6 +945,7 @@ static void neigh_timer_handler(unsigned long arg)
 		neigh->nud_state = NUD_FAILED;
 		notify = 1;
 		neigh_invalidate(neigh);
+		goto out;
 	}
 
 	if (neigh->nud_state & NUD_IN_TIMER) {
-- 
1.8.3.1
