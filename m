From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/core/scm.c: make scm_detach_fds() static
Date: Sat, 18 Mar 2006 19:45:31 +0100
Message-ID: <20060318184531.GG14608@stusta.de>
References: <20060318044056.350a2931.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750796AbWCRSqB@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060318044056.350a2931.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 18, 2006 at 04:40:56AM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.16-rc6-mm1:
>...
>  git-net.patch
>...
>  git trees.
>...


We can now make scm_detach_fds() static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/scm.h |    1 -
 net/core/scm.c    |    3 +--
 2 files changed, 1 insertion(+), 3 deletions(-)

--- linux-2.6.16-rc6-mm2-full/include/net/scm.h.old	2006-03-18 18:48:20.000000000 +0100
+++ linux-2.6.16-rc6-mm2-full/include/net/scm.h	2006-03-18 18:48:25.000000000 +0100
@@ -24,7 +24,6 @@
 	unsigned long		seq;		/* Connection seqno	*/
 };
 
-extern void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm);
 extern void scm_detach_fds_compat(struct msghdr *msg, struct scm_cookie *scm);
 extern void __scm_destroy(struct scm_cookie *scm);
 extern struct scm_fp_list * scm_fp_dup(struct scm_fp_list *fpl);
--- linux-2.6.16-rc6-mm2-full/net/core/scm.c.old	2006-03-18 18:48:35.000000000 +0100
+++ linux-2.6.16-rc6-mm2-full/net/core/scm.c	2006-03-18 18:48:46.000000000 +0100
@@ -210,7 +210,7 @@
 	return err;
 }
 
-void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
+static void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 {
 	struct cmsghdr __user *cm = (struct cmsghdr __user*)msg->msg_control;
 
@@ -329,5 +329,4 @@
 EXPORT_SYMBOL(scm_send);
 EXPORT_SYMBOL(scm_recv);
 EXPORT_SYMBOL(put_cmsg);
-EXPORT_SYMBOL(scm_detach_fds);
 EXPORT_SYMBOL(scm_fp_dup);
