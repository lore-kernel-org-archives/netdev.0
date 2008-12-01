From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] xfrm: Fix kernel panic when flush and dump SPD entries
Date: Mon, 01 Dec 2008 10:00:34 +0800
Message-ID: <49334542.3070502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58403 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753004AbYLAB72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Nov 2008 20:59:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After flush the SPD entries, dump the SPD entries will cause kernel painc.

Used the following commands to reproduct:

ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
spddump;' | setkey -c
ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
spddump;' | setkey -c

This is because when flush the SPD entries, the SPD entry is not remove
from the list.

This patch fix the problem by remove the SPD entry from the list.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/xfrm/xfrm_policy.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 058f04f..fb216c9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -817,6 +817,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 				continue;
 			hlist_del(&pol->bydst);
 			hlist_del(&pol->byidx);
+			list_del(&pol->walk.all);
 			write_unlock_bh(&xfrm_policy_lock);
 
 			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
-- 
1.6.0.2.530.g67faa



