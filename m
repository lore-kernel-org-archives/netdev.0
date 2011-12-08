From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] sock_diag: off by one checks
Date: Thu, 8 Dec 2011 09:49:38 +0300
Message-ID: <20111208064938.GB16735@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:38058 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab1LHGt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 01:49:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These tests are off by one because sock_diag_handlers[] only has AF_MAX
elements.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index fbaf01c..9c27bcd 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -32,7 +32,7 @@ int sock_diag_register(struct sock_diag_handler *hndl)
 {
 	int err = 0;
 
-	if (hndl->family > AF_MAX)
+	if (hndl->family >= AF_MAX)
 		return -EINVAL;
 
 	mutex_lock(&sock_diag_table_mutex);
@@ -50,7 +50,7 @@ void sock_diag_unregister(struct sock_diag_handler *hnld)
 {
 	int family = hnld->family;
 
-	if (family > AF_MAX)
+	if (family >= AF_MAX)
 		return;
 
 	mutex_lock(&sock_diag_table_mutex);
