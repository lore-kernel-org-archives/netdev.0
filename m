From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: [PATCH] netconsole: enable netconsole can make net_device refcnt
Date: Tue, 11 Oct 2011 15:50:38 +0800
Message-ID: <1318319438-7159-1-git-send-email-gaowanlong@cn.fujitsu.com>
References: <4E93E238.7000105@cn.fujitsu.com>
Cc: davem@davemloft.net, Wanlong Gao <gaowanlong@cn.fujitsu.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49480 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753276Ab1JKHvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 03:51:52 -0400
In-Reply-To: <4E93E238.7000105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no check if netconsole is enabled current.
so when exec echo 1 > enabled;
the reference of net_device will increment always.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/netconsole.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ed2a397..4e6323df 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -307,6 +307,8 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		return err;
 	if (enabled < 0 || enabled > 1)
 		return -EINVAL;
+	if (enabled == nt->enabled)
+		return err;
 
 	if (enabled) {	/* 1 */
 
-- 
1.7.7.rc1
