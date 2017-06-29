From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: bridge: constify attribute_group structures.
Date: Thu, 29 Jun 2017 16:39:38 +0530
Message-ID: <dc7089d0bab72d77ef4819b7d46c8cf88cae6588.1498734476.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stephen@networkplumber.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33593 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751837AbdF2LK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 07:10:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work with const
attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   2645	    896	      0	   3541	    dd5	net/bridge/br_sysfs_br.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   2701	    832	      0	   3533	    dcd	net/bridge/br_sysfs_br.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/bridge/br_sysfs_br.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 0b5dd60..723f25e 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -865,7 +865,7 @@ static ssize_t vlan_stats_enabled_store(struct device *d,
 	NULL
 };
 
-static struct attribute_group bridge_group = {
+static const struct attribute_group bridge_group = {
 	.name = SYSFS_BRIDGE_ATTR,
 	.attrs = bridge_attrs,
 };
-- 
1.9.1
