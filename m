From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 5/5] RDS: Add a debug message suggesting to load transport modules
Date: Fri, 21 Aug 2009 15:28:35 -0700
Message-ID: <1250893715-21939-6-git-send-email-andy.grover@oracle.com>
References: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:24512 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933045AbZHUW2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 18:28:52 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7LMSjFI016288
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 22:28:46 GMT
In-Reply-To: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that RDS transports are no longer compiled-in to RDS core,
there is now the possibility that they will not be loaded. This
adds a helpful suggestion when rds_bind() fails to find a transport.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/bind.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index c17cc39..5d95fc0 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -187,6 +187,9 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (trans == NULL) {
 		ret = -EADDRNOTAVAIL;
 		rds_remove_bound(rs);
+		if (printk_ratelimit())
+			printk(KERN_INFO "RDS: rds_bind() could not find a transport, "
+				"load rds_tcp or rds_rdma?\n");
 		goto out;
 	}
 
-- 
1.6.0.4

