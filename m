From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NOMMU: Make lib/ioremap.c conditional
Date: Tue, 05 Sep 2006 16:31:22 +0100
Message-ID: <6130.1157470282@warthog.cambridge.redhat.com>
References: <20060905132530.GD9173@stusta.de>  <20060901015818.42767813.akpm@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:26601 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965120AbWIEPdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 11:33:07 -0400
In-Reply-To: <20060905132530.GD9173@stusta.de> 
To: Adrian Bunk <bunk@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Make lib/ioremap.c conditional on !CONFIG_MMU.  It plays with PTEs which don't
exist under NOMMU conditions.

Signed-Off-By: David Howells <dhowells@redhat.com>
---
warthog>diffstat -p1 nommu-ioremap-2618rc5mm1.diff 
 lib/Makefile |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -urp ../kernels/linux-2.6.18-rc5-mm1/lib/Makefile linux-2.6.18-rc5-mm1-frv/lib/Makefile
--- ../kernels/linux-2.6.18-rc5-mm1/lib/Makefile	2006-09-04 18:03:32.000000000 +0100
+++ linux-2.6.18-rc5-mm1-frv/lib/Makefile	2006-09-05 16:01:38.000000000 +0100
@@ -5,8 +5,9 @@
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 bust_spinlocks.o rbtree.o radix-tree.o dump_stack.o \
 	 idr.o div64.o int_sqrt.o bitmap.o extable.o prio_tree.o \
-	 sha1.o ioremap.o
+	 sha1.o
 
+lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
 
 lib-y	+= kobject.o kref.o kobject_uevent.o klist.o
