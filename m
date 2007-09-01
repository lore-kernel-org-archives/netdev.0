From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 1/3] netlink: use the macro min(x,y) provided by <linux/kernel.h> instead
Date: Sun,  2 Sep 2007 03:45:57 +0800
Message-ID: <1188675959178-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:61914 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbXIATqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 15:46:22 -0400
Received: by rv-out-0910.google.com with SMTP id k20so653843rvb
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2007 12:46:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5681ce3..8bb14e3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1905,7 +1905,7 @@ static int __init netlink_proto_init(void)
 
 	order = get_bitmask_order(max) - 1 + PAGE_SHIFT;
 	max = (1UL << order) / sizeof(struct hlist_head);
-	order = get_bitmask_order(max > UINT_MAX ? UINT_MAX : max) - 1;
+	order = get_bitmask_order(min(max, (unsigned long)UINT_MAX)) - 1;
 
 	for (i = 0; i < MAX_LINKS; i++) {
 		struct nl_pid_hash *hash = &nl_table[i].hash;
-- 
1.5.3.rc7

