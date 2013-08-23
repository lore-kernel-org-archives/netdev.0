From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH ipsec-next] xfrm: announce deleation of temporary SA
Date: Fri, 23 Aug 2013 15:46:08 +0200
Message-ID: <1377265568-10959-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56059 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866Ab3HWNqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 09:46:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creation of temporary SA are announced by netlink, but there is no notification
for the deletion.
This patch fix this asymmetric situation.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Example:
ip xfrm monitor
acquire proto esp 
  sel src 10.22.6.51/32 dst 10.24.6.139/32 proto icmp type 8 code 0 
  policy src 10.22.6.51/32 dst 10.24.6.139/32 
    	dir out priority 3843 ptype main 
    	tmpl src 10.23.6.106 dst 10.23.6.206
    		proto esp reqid 2147483649 mode tunnel
Expired src 10.23.6.106 dst 10.23.6.206
	proto esp spi 0x00000000 reqid 2147483649 mode tunnel
	replay-window 0 
	sel src 10.22.6.51/32 dst 10.24.6.139/32 proto icmp type 8 code 0 
	hard 1

 net/xfrm/xfrm_state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4f8ace855864..3fd65b73df7e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -471,7 +471,7 @@ expired:
 	}
 
 	err = __xfrm_state_delete(x);
-	if (!err && x->id.spi)
+	if (!err)
 		km_state_expired(x, 1, 0);
 
 	xfrm_audit_state_delete(x, err ? 0 : 1,
-- 
1.8.2.1
