From: "majianpeng" <majianpeng@gmail.com>
Subject: [PATCH] net/ipv4:Remove two reports using kmemleak
Date: Mon, 16 Apr 2012 19:40:22 +0800
Message-ID: <201204161940178124485@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "davem" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:43723 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab2DPLjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 07:39:41 -0400
Received: by dake40 with SMTP id e40so6807200dak.11
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 04:39:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 8eb7c077dd3e746476a2a9fe059a676a6bc1a61f Mon Sep 17 00:00:00 2001
From: majianpeng <majianpeng@gmail.com>
Date: Mon, 16 Apr 2012 19:34:50 +0800
Subject: [PATCH] net/ipv4:Remove two reports using kmemleak. Although those
 two reports do not real kmemleak,I think can remove it  better.

Reported by kmemleak:
unreferenced object 0xffff8800b8735090 (size 96):
  comm "swapper/0", pid 1, jiffies 4294670057 (age 542.870s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff81695df1>] kmemleak_alloc+0x21/0x50
    [<ffffffff81117c3b>] __kmalloc+0x11b/0x1f0
    [<ffffffff81188f57>] __register_sysctl_paths+0x127/0x1f0
    [<ffffffff81189036>] register_sysctl_paths+0x16/0x20
    [<ffffffff81cf1fc7>] ip_static_sysctl_init+0x17/0x19
    [<ffffffff81cf2924>] inet_init+0xb4/0x2b2
    [<ffffffff810001ca>] do_one_initcall+0x3a/0x160
    [<ffffffff81cb9c7e>] kernel_init+0x12e/0x1b2
    [<ffffffff816bdb94>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8800b8735730 (size 96):
  comm "swapper/0", pid 1, jiffies 4294670057 (age 542.870s)
  hex dump (first 32 bytes):
    80 80 e3 81 ff ff ff ff 00 00 00 00 01 00 00 00  ................
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff81695df1>] kmemleak_alloc+0x21/0x50
    [<ffffffff81117c3b>] __kmalloc+0x11b/0x1f0
    [<ffffffff81188792>] __register_sysctl_table+0x62/0x4b0
    [<ffffffff81188da5>] register_leaf_sysctl_tables+0x1c5/0x230
    [<ffffffff81188ca0>] register_leaf_sysctl_tables+0xc0/0x230
    [<ffffffff81188f89>] __register_sysctl_paths+0x159/0x1f0
    [<ffffffff81189036>] register_sysctl_paths+0x16/0x20
    [<ffffffff81cf1fc7>] ip_static_sysctl_init+0x17/0x19
    [<ffffffff81cf2924>] inet_init+0xb4/0x2b2
    [<ffffffff810001ca>] do_one_initcall+0x3a/0x160
    [<ffffffff81cb9c7e>] kernel_init+0x12e/0x1b2
    [<ffffffff816bdb94>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff


Signed-off-by: majianpeng <majianpeng@gmail.com>
---
 net/ipv4/route.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 167ea10..817207b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3499,12 +3499,13 @@ int __init ip_rt_init(void)
 }
 
 #ifdef CONFIG_SYSCTL
+static struct ctl_table_header *sysctl_header;
 /*
  * We really need to sanitize the damn ipv4 init order, then all
  * this nonsense will go away.
  */
 void __init ip_static_sysctl_init(void)
 {
-	register_sysctl_paths(ipv4_path, ipv4_skeleton);
+	sysctl_header = register_sysctl_paths(ipv4_path, ipv4_skeleton);
 }
 #endif
-- 
1.7.5.4

 				
--------------
majianpeng
2012-04-16
