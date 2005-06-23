From: Jeff Moyer <jmoyer@redhat.com>
Subject: [patch 1/3] netpoll: set poll_owner to -1 before unlocking in netpoll_poll_unlock
Date: Wed, 22 Jun 2005 21:27:38 -0400
Message-ID: <17082.4106.825017.811757@segfault.boston.redhat.com>
References: <17082.4037.875432.648439@segfault.boston.redhat.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261889AbVFWB2U@vger.kernel.org>
To: mpm@selenic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org
In-Reply-To: <17082.4037.875432.648439@segfault.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This trivial patch moves the assignment of poll_owner to -1 inside of the
lock.  This fixes a potential SMP race in the code.

-Jeff

Signed-off-by: Jeff Moyer <jmoyer@redhat.com>
---

--- linux-2.6.12/include/linux/netpoll.h.orig	2005-06-22 18:47:12.917261688 -0400
+++ linux-2.6.12/include/linux/netpoll.h	2005-06-22 18:47:15.799783018 -0400
@@ -53,8 +53,8 @@ static inline void netpoll_poll_lock(str
 static inline void netpoll_poll_unlock(struct net_device *dev)
 {
 	if (dev->np) {
-		spin_unlock(&dev->np->poll_lock);
 		dev->np->poll_owner = -1;
+		spin_unlock(&dev->np->poll_lock);
 	}
 }
 
