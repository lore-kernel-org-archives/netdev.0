From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Subject: [PATCH 09/10] cfq-iosched: Uses its own open-coded rcu_barrier.
Date: Tue, 23 Jun 2009 17:04:39 +0200
Message-ID: <20090623150439.22490.14657.stgit@localhost>
References: <20090623150330.22490.87327.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dougthompson-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bluesmoke-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, "Patrick McHardy" <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This module cfq-iosched, has discovered the value of waiting for
call_rcu() completion, but its has its own open-coded implementation
of rcu_barrier(), which I don't think is 'strong' enough.

This patch only leaves a comment for the maintainers to consider.

Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
---

 block/cfq-iosched.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 833ec18..c15555b 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2657,6 +2657,12 @@ static void __exit cfq_exit(void)
 	/*
 	 * this also protects us from entering cfq_slab_kill() with
 	 * pending RCU callbacks
+	 *
+	 * hawk-4UpuNZONu4c@public.gmane.org 2009-06-18: Maintainer please consider using
+	 *  rcu_barrier() instead of this open-coded wait for
+	 *  completion implementation.  I think it provides a better
+	 *  guarantee that all CPUs are finished, although
+	 *  elv_ioc_count_read() do consider all CPUs.
 	 */
 	if (elv_ioc_count_read(ioc_count))
 		wait_for_completion(&all_gone);

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
