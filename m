From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [rfc | patch 0/6] netpoll: add support for the bonding driver
Date: Fri, 1 Jul 2005 19:06:26 -0400
Message-ID: <17093.52338.481897.207125@segfault.boston.redhat.com>
References: <17093.52306.136742.190912@segfault.boston.redhat.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261629AbVGAXGe@vger.kernel.org>
To: mpm@selenic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
In-Reply-To: <17093.52306.136742.190912@segfault.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialize npinfo->rx_flags.  The way it stands now, this will have random
garbage, and so will incur a locking penalty even when an rx_hook isn't
registered and we are not active in the netpoll polling code.

Signed-off-by: Jeff Moyer <jmoyer@redhat.com>
---

--- linux-2.6.12/net/core/netpoll.c.orig	2005-07-01 14:02:56.039174635 -0400
+++ linux-2.6.12/net/core/netpoll.c	2005-07-01 14:03:16.688739508 -0400
@@ -639,6 +639,7 @@ int netpoll_setup(struct netpoll *np)
 		if (!npinfo)
 			goto release;
 
+		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
 		npinfo->poll_lock = SPIN_LOCK_UNLOCKED;
 		npinfo->poll_owner = -1;
