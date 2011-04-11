From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 PATCH] ethtool: time to blink provided in seconds not
	jiffies
Date: Mon, 11 Apr 2011 16:01:59 -0700
Message-ID: <20110411230159.6727.91380.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10372 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756310Ab1DKXCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 19:02:30 -0400
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id p3BN1xUF006756
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 16:01:59 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When blinking for a duration set by the user, the value specified is in
seconds but it is used as the number of jiffies in the timeout after which
the Physical ID indicator is deactivated.  Fix by converting the timeout
to seconds.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---

 net/core/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 704e176..43ef09f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1653,7 +1653,7 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 	if (rc == 0) {
 		/* Driver will handle this itself */
 		schedule_timeout_interruptible(
-			id.data ? id.data : MAX_SCHEDULE_TIMEOUT);
+			id.data ? (id.data * HZ) : MAX_SCHEDULE_TIMEOUT);
 	} else {
 		/* Driver expects to be called periodically */
 		do {

