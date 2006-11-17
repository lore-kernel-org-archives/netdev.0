From: paul.moore@hp.com
Subject: [PATCH 08/13] NetLabel: return the correct error for translated CIPSOv4 tags
Date: Fri, 17 Nov 2006 17:38:50 -0500
Message-ID: <20061117224335.464740000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:22421 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1755992AbWKQWnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:37 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_errcode
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The CIPSOv4 translated tag #1 mapping does not always return the correct error
code if the desired mapping does not exist; instead of returning -EPERM it
returns -ENOSPC indicating that the buffer is not large enough to hold the
translated value.  This was caused by failing to check a specific error
condition.  This patch fixes this so that unknown mappings return
-EPERM which is consistent with the rest of the related CIPSOv4 code.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |    4 ++++
 1 files changed, 4 insertions(+)

Index: net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
@@ -868,6 +868,8 @@ static int cipso_v4_map_cat_rbm_hton(con
 				return -EPERM;
 
 			net_spot = host_cat_array[host_spot];
+			if (net_spot >= CIPSO_V4_INV_CAT)
+				return -EPERM;
 			if (net_spot >= net_clen_bits)
 				return -ENOSPC;
 			cipso_v4_bitmap_setbit(net_cat, net_spot, 1);
@@ -936,6 +938,8 @@ static int cipso_v4_map_cat_rbm_ntoh(con
 				return -EPERM;
 
 			host_spot = net_cat_array[net_spot];
+			if (host_spot >= CIPSO_V4_INV_CAT)
+				return -EPERM;
 			if (host_spot >= host_clen_bits)
 				return -ENOSPC;
 			cipso_v4_bitmap_setbit(host_cat, host_spot, 1);

--
paul moore
linux security @ hp
