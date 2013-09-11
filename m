From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] xen-netback: fix possible format string flaw
Date: Tue, 10 Sep 2013 21:39:11 -0700
Message-ID: <20130911043911.GA17237@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <ian.campbell@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes sure a format string cannot accidentally leak into the
kthread_run() call.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/xen-netback/interface.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 625c6f4..77fee1d 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -406,7 +406,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	init_waitqueue_head(&vif->wq);
 	vif->task = kthread_create(xenvif_kthread,
-				   (void *)vif, vif->dev->name);
+				   (void *)vif, "%s", vif->dev->name);
 	if (IS_ERR(vif->task)) {
 		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
 		err = PTR_ERR(vif->task);
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security
