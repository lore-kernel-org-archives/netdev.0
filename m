From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/3] NET: Fix networking compilation errors
Date: Fri, 27 Apr 2007 15:31:45 +0100
Message-ID: <20070427143145.23545.28816.stgit@warthog.cambridge.redhat.com>
References: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755940AbXD0Obr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 10:31:47 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3REVkM6030697
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 10:31:47 -0400
In-Reply-To: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix miscellaneous networking compilation errors.

 (*) Export ktime_add_ns() for modules.

 (*) wext_proc_init() should have an ANSI declaration.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 include/net/wext.h |    2 +-
 kernel/hrtimer.c   |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/wext.h b/include/net/wext.h
index 5574183..c02b8de 100644
--- a/include/net/wext.h
+++ b/include/net/wext.h
@@ -10,7 +10,7 @@ extern int wext_proc_init(void);
 extern int wext_handle_ioctl(struct ifreq *ifr, unsigned int cmd,
 			     void __user *arg);
 #else
-static inline int wext_proc_init()
+static inline int wext_proc_init(void)
 {
 	return 0;
 }
diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index f5cfde8..1b30331 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -279,6 +279,8 @@ ktime_t ktime_add_ns(const ktime_t kt, u64 nsec)
 
 	return ktime_add(kt, tmp);
 }
+
+EXPORT_SYMBOL_GPL(ktime_add_ns);
 # endif /* !CONFIG_KTIME_SCALAR */
 
 /*

