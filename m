From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 03/13] RDS: update copy_to_user state in tcp transport
Date: Thu, 11 Mar 2010 15:49:57 -0800
Message-ID: <1268351407-7394-4-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:56786 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645Ab0CKXvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:51:00 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNowPL001412
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:51:00 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Other transports use rds_page_copy_user, which updates our
s_copy_to_user counter. TCP doesn't, so it needs to explicity
call rds_stats_add().

Reported-by: Richard Frank <richard.frank@oracle.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/tcp_recv.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index c00daff..40bfcf8 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -97,6 +97,7 @@ int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iovec *first_iov,
 				goto out;
 			}
 
+			rds_stats_add(s_copy_to_user, to_copy);
 			size -= to_copy;
 			ret += to_copy;
 			skb_off += to_copy;
-- 
1.6.3.3

