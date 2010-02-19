From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/2] net-sysfs: Use rtnl_trylock in wireless sysfs methods.
Date: Fri, 19 Feb 2010 15:23:47 -0800
Message-ID: <m1zl34stbw.fsf@fess.ebiederm.org>
References: <m14olcu7xo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59082 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab0BSXXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:23:52 -0500
In-Reply-To: <m14olcu7xo.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 19 Feb 2010 15\:22\:59 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The wireless sysfs methods like the rest of the networking sysfs
methods are removed with the rtnl_lock held and block until
the existing methods stop executing.  So use rtnl_trylock
and restart_syscall so that the code continues to work.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/net-sysfs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index fbc1c74..099c753 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -410,7 +410,8 @@ static ssize_t wireless_show(struct device *d, char *buf,
 	const struct iw_statistics *iw;
 	ssize_t ret = -EINVAL;
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	if (dev_isalive(dev)) {
 		iw = get_wireless_stats(dev);
 		if (iw)
-- 
1.6.5.2.143.g8cc62

