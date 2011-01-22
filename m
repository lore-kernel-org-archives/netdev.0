From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v5 15/27] rds: use little-endian bitops
Date: Sat, 22 Jan 2011 22:13:47 +0900
Message-ID: <1295702039-23186-16-git-send-email-akinobu.mita@gmail.com>
References: <1295702039-23186-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Andy Grover <andy.grover@oracle.com>, rds-devel@oss.oracle.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52422 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339Ab1AVNO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 08:14:27 -0500
In-Reply-To: <1295702039-23186-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a preparation for removing ext2 non-atomic bit operations from
asm/bitops.h.  This converts ext2 non-atomic bit operations to
little-endian bit operations.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andy Grover <andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---

Change from v4:
 - splitted into two patches to fix a bisection hole

The whole series is available in the git branch at:
 git://git.kernel.org/pub/scm/linux/kernel/git/mita/linux-2.6.git le-bitops-v5

 net/rds/cong.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index 8cc322b..6daaa49 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -284,7 +284,7 @@ void rds_cong_set_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	ext2_set_bit(off, (void *)map->m_page_addrs[i]);
+	__set_bit_le(off, (void *)map->m_page_addrs[i]);
 }
 
 void rds_cong_clear_bit(struct rds_cong_map *map, __be16 port)
@@ -298,7 +298,7 @@ void rds_cong_clear_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	ext2_clear_bit(off, (void *)map->m_page_addrs[i]);
+	__clear_bit_le(off, (void *)map->m_page_addrs[i]);
 }
 
 static int rds_cong_test_bit(struct rds_cong_map *map, __be16 port)
@@ -309,7 +309,7 @@ static int rds_cong_test_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	return ext2_test_bit(off, (void *)map->m_page_addrs[i]);
+	return test_bit_le(off, (void *)map->m_page_addrs[i]);
 }
 
 void rds_cong_add_socket(struct rds_sock *rs)
-- 
1.7.3.4

