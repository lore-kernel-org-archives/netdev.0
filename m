From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net/netlabel: copy and paste bug in
 netlbl_cfg_unlbl_map_add()
Date: Thu, 24 Nov 2011 10:18:20 +0300
Message-ID: <20111124071820.GB14122@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:33868 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab1KXHSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 02:18:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was copy and pasted from the IPv4 code.  We're calling the
ip4 version of that function and map4 is NULL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 8ed67dcc..3735297 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -162,8 +162,8 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			map6->list.addr.s6_addr32[3] &= mask6->s6_addr32[3];
 			map6->list.mask = *mask6;
 			map6->list.valid = 1;
-			ret_val = netlbl_af4list_add(&map4->list,
-						     &addrmap->list4);
+			ret_val = netlbl_af6list_add(&map6->list,
+						     &addrmap->list6);
 			if (ret_val != 0)
 				goto cfg_unlbl_map_add_failure;
 			break;
