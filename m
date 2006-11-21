From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 11/11] [XFRM]: Use kmemdup where appropriate
Date: Tue, 21 Nov 2006 01:29:35 -0200
Message-ID: <20061121032935.GL7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:23021 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030692AbWKUD3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:29:40 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/xfrm/xfrm_user.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1598bf6..54f1eea 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -244,11 +244,10 @@ static int attach_one_algo(struct xfrm_a
 	*props = algo->desc.sadb_alg_id;
 
 	len = sizeof(*ualg) + (ualg->alg_key_len + 7U) / 8;
-	p = kmalloc(len, GFP_KERNEL);
+	p = kmemdup(ualg, len, GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	memcpy(p, ualg, len);
 	strcpy(p->alg_name, algo->name);
 	*algpp = p;
 	return 0;
@@ -263,11 +262,10 @@ static int attach_encap_tmpl(struct xfrm
 		return 0;
 
 	uencap = RTA_DATA(rta);
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	p = kmemdup(uencap, sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	memcpy(p, uencap, sizeof(*p));
 	*encapp = p;
 	return 0;
 }
@@ -305,11 +303,10 @@ static int attach_one_addr(xfrm_address_
 		return 0;
 
 	uaddrp = RTA_DATA(rta);
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	p = kmemdup(uaddrp, sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	memcpy(p, uaddrp, sizeof(*p));
 	*addrpp = p;
 	return 0;
 }
-- 
1.4.2.1.g3d5c

