From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] Net / pktgen: Fix freezing problem
Date: Thu, 4 Feb 2010 22:50:58 +0100
Message-ID: <201002042250.58944.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ciprian Dorin Craciun <ciprian.craciun@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: Net / pktgen: Fix freezing problem

Add missing try_to_freeze() to one of the pktgen_thread_worker() code
paths so that it doesn't block suspend/hibernation.

Fixes http://bugzilla.kernel.org/show_bug.cgi?id=15006

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
Reported-and-tested-by: Ciprian Dorin Craciun <ciprian.craciun@gmail.com>
---
 net/core/pktgen.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/net/core/pktgen.c
===================================================================
--- linux-2.6.orig/net/core/pktgen.c
+++ linux-2.6/net/core/pktgen.c
@@ -3524,6 +3524,7 @@ static int pktgen_thread_worker(void *ar
 			wait_event_interruptible_timeout(t->queue,
 							 t->control != 0,
 							 HZ/10);
+			try_to_freeze();
 			continue;
 		}
 
