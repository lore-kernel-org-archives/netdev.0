From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] netdev: get rid of casts
Date: Tue, 24 Apr 2007 10:46:50 -0700
Message-ID: <20070424104650.3523479d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:35602 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422889AbXDXRtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 13:49:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following casts are unnecessary, just passing void * will do.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/dev.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 18c51b4..61e9da2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1981,7 +1981,7 @@ int register_gifconf(unsigned int family, gifconf_func_t * gifconf)
  *	match.  --pb
  */
 
-static int dev_ifname(struct ifreq __user *arg)
+static int dev_ifname(void __user *arg)
 {
 	struct net_device *dev;
 	struct ifreq ifr;
@@ -2014,7 +2014,7 @@ static int dev_ifname(struct ifreq __user *arg)
  *	Thus we will need a 'compatibility mode'.
  */
 
-static int dev_ifconf(char __user *arg)
+static int dev_ifconf(void __user *arg)
 {
 	struct ifconf ifc;
 	struct net_device *dev;
@@ -2778,12 +2778,12 @@ int dev_ioctl(unsigned int cmd, void __user *arg)
 
 	if (cmd == SIOCGIFCONF) {
 		rtnl_lock();
-		ret = dev_ifconf((char __user *) arg);
+		ret = dev_ifconf(arg);
 		rtnl_unlock();
-		return ret;
 	}
+
 	if (cmd == SIOCGIFNAME)
-		return dev_ifname((struct ifreq __user *)arg);
+		return dev_ifname(arg);
 
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;
-- 
1.5.0.6

