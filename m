From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] xps: NUMA allocations for per cpu data
Date: Sun, 28 Nov 2010 16:43:24 +0100
Message-ID: <1290959004.29196.13.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	 <20101124.114534.15255941.davem@davemloft.net>
	 <AANLkTi=8smjJgTXxe7vj8AHAMceLUr25KurZbm07vP1j@mail.gmail.com>
	 <1290791866.2855.263.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49507 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab0K1Pn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 10:43:29 -0500
Received: by wyb28 with SMTP id 28so3553489wyb.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 07:43:28 -0800 (PST)
In-Reply-To: <1290791866.2855.263.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

store_xps_map() allocates maps that are used by single cpu, it makes
sense to use NUMA allocations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/core/net-sysfs.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 68dbbfd..35f28b1 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -950,8 +950,9 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 			if (map_len >= alloc_len) {
 				alloc_len = alloc_len ?
 				    2 * alloc_len : XPS_MIN_MAP_ALLOC;
-				new_map = kzalloc(XPS_MAP_SIZE(alloc_len),
-				    GFP_KERNEL);
+				new_map = kzalloc_node(XPS_MAP_SIZE(alloc_len),
+						       GFP_KERNEL,
+						       cpu_to_node(cpu));
 				if (!new_map)
 					goto error;
 				new_map->alloc_len = alloc_len;


