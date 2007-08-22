From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 14/16] [XFRM] netlink: Use nla_memcpy() in xfrm_update_ae_params()
Date: Wed, 22 Aug 2007 16:55:52 +0200
Message-ID: <20070822145631.785314805@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56973 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763280AbXHVP3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:18 -0400
Content-Disposition: inline; filename=xfrm_nla_memcpy
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:35:13.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:36:59.000000000 +0200
@@ -303,20 +303,12 @@ static void xfrm_update_ae_params(struct
 	struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
 
 	if (rp) {
-		struct xfrm_replay_state *replay;
-		replay = nla_data(rp);
-		memcpy(&x->replay, replay, sizeof(*replay));
-		memcpy(&x->preplay, replay, sizeof(*replay));
+		nla_memcpy(&x->replay, rp, sizeof(x->replay));
+		nla_memcpy(&x->preplay, rp, sizeof(x->preplay));
 	}
 
-	if (lt) {
-		struct xfrm_lifetime_cur *ltime;
-		ltime = nla_data(lt);
-		x->curlft.bytes = ltime->bytes;
-		x->curlft.packets = ltime->packets;
-		x->curlft.add_time = ltime->add_time;
-		x->curlft.use_time = ltime->use_time;
-	}
+	if (lt)
+		nla_memcpy(&x->curlft, lt, sizeof(x->curlft));
 
 	if (et)
 		x->replay_maxage = nla_get_u32(et);

-- 

