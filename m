From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: constify attribute_group structures.
Date: Thu, 29 Jun 2017 16:31:26 +0530
Message-ID: <7e920337fab72cc388b20ac95c2e198b84145483.1498733815.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, jasowang@redhat.com, mingo@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35009 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdF2LCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 07:02:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/device.h> work with const
attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   9968	   3168	     16	  13152	   3360	net/core/net-sysfs.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  10160	   2976	     16	  13152	   3360	net/core/net-sysfs.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/core/net-sysfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 65ea0ff..85daa29 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -622,7 +622,7 @@ static DEVICE_ATTR_RO(name)
 };
 
 
-static struct attribute_group netstat_group = {
+static const struct attribute_group netstat_group = {
 	.name  = "statistics",
 	.attrs  = netstat_attrs,
 };
@@ -632,7 +632,7 @@ static DEVICE_ATTR_RO(name)
 	NULL
 };
 
-static struct attribute_group wireless_group = {
+static const struct attribute_group wireless_group = {
 	.name = "wireless",
 	.attrs = wireless_attrs,
 };
@@ -1200,7 +1200,7 @@ static ssize_t bql_show_inflight(struct netdev_queue *queue,
 	NULL
 };
 
-static struct attribute_group dql_group = {
+static const struct attribute_group dql_group = {
 	.name  = "byte_queue_limits",
 	.attrs  = dql_attrs,
 };
-- 
1.9.1
