From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/4] net ipv4: Remove unnecessary test for the loopback device from inetdev_destroy
Date: Wed, 26 Sep 2007 17:55:29 -0600
Message-ID: <m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:49573 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbXIZX4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 19:56:13 -0400
In-Reply-To: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's
	message of "Wed, 26 Sep 2007 17:53:40 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently we never call unregister_netdev for the loopback device so
it is impossible for us to reach inetdev_destroy with the loopback
device.  So the test in inetdev_destroy is unnecessary.

Further when testing with my network namespace patches removing
unregistering the loopback device and calling inetdev_destroy works
fine so there appears to be no reason for avoiding unregistering the
loopback device.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/devinet.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index affea9b..e7f2b02 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -203,8 +203,6 @@ static void inetdev_destroy(struct in_device *in_dev)
 	ASSERT_RTNL();
 
 	dev = in_dev->dev;
-	if (dev == loopback_dev)
-		return;
 
 	in_dev->dead = 1;
 
-- 
1.5.3.rc6.17.g1911

