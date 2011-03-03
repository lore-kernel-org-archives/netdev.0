From: Chris Wright <chrisw@sous-sol.org>
Subject: [RFC PATCH 4/2] connector: update callbacks to use
 security_netlink_recv()
Date: Thu, 3 Mar 2011 12:30:12 -0800
Message-ID: <20110303203012.GW4988@sequoia.sous-sol.org>
References: <20110303202626.GV4988@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>, netdev@vger.kernel.org,
	dm-devel@redhat.com, linux-security-module@vger.kernel.org,
	drbd-dev@lists.linbit.com, Evgeniy Polyakov <zbr@ioremap.net>,
	linux-fbdev@vger.kernel.org
To: James Morris <jmorris@namei.org>, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:36297 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752594Ab1CCUaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 15:30:35 -0500
Content-Disposition: inline
In-Reply-To: <20110303202626.GV4988@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves callbacks from a raw capabiliity hook to the generic lsm hook
when receiving request from userspace.

Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
 drivers/block/drbd/drbd_nl.c           |    2 +-
 drivers/md/dm-log-userspace-transfer.c |    2 +-
 drivers/staging/pohmelfs/config.c      |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index fe81c85..8b3301b 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -2177,7 +2177,7 @@ static void drbd_connector_callback(struct cn_msg *req, struct netlink_skb_parms
 		return;
 	}
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
+	if (security_netlink_recv(CAP_SYS_ADMIN)) {
 		retcode = ERR_PERM;
 		goto fail;
 	}
diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-userspace-transfer.c
index 1f23e04..db34a3a 100644
--- a/drivers/md/dm-log-userspace-transfer.c
+++ b/drivers/md/dm-log-userspace-transfer.c
@@ -134,7 +134,7 @@ static void cn_ulog_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (security_netlink_recv(CAP_SYS_ADMIN))
 		return;
 
 	spin_lock(&receiving_list_lock);
diff --git a/drivers/staging/pohmelfs/config.c b/drivers/staging/pohmelfs/config.c
index 39413b7..123295a 100644
--- a/drivers/staging/pohmelfs/config.c
+++ b/drivers/staging/pohmelfs/config.c
@@ -525,7 +525,7 @@ static void pohmelfs_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *n
 {
 	int err;
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (security_netlink_recv(CAP_SYS_ADMIN))
 		return;
 
 	switch (msg->flags) {
diff --git a/drivers/video/uvesafb.c b/drivers/video/uvesafb.c
index 5180a21..081463a 100644
--- a/drivers/video/uvesafb.c
+++ b/drivers/video/uvesafb.c
@@ -73,7 +73,7 @@ static void uvesafb_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *ns
 	struct uvesafb_task *utask;
 	struct uvesafb_ktask *task;
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (security_netlink_recv(CAP_SYS_ADMIN))
 		return;
 
 	if (msg->seq >= UVESAFB_TASKS_MAX)
-- 
1.7.1
