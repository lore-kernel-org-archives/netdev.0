From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v2] netconsole: enable netconsole can make net_device refcnt incorrent
Date: Wed, 12 Oct 2011 10:08:11 +0800
Message-ID: <1318385291-15483-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fbl@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59737 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750838Ab1JLCH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 22:07:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no check if netconsole is enabled current.
so when exec echo 1 > enabled;
the reference of net_device will increment always.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/netconsole.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ed2a397..e888202 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -307,6 +307,11 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		return err;
 	if (enabled < 0 || enabled > 1)
 		return -EINVAL;
+	if (enabled == nt->enabled) {
+		printk(KERN_INFO "netconsole: network logging has already %s\n",
+				nt->enabled ? "started" : "stopped");
+		return -EINVAL;
+	}
 
 	if (enabled) {	/* 1 */
 
-- 
1.7.1
