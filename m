From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] cxgb4: Remove unnecessary struct in6_addr * casts
Date: Thu, 06 Nov 2014 20:46:14 -0800
Message-ID: <1415335574.23530.4.camel@perches.com>
References: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
	 <1415333125-10635-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	anish@chelsio.com, praveenm@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0191.hostedemail.com ([216.40.44.191]:51370 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751371AbaKGEqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 23:46:21 -0500
In-Reply-To: <1415333125-10635-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just use the address of the in6_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
[]
>  #include <../drivers/net/bonding/bonding.h>

This include path seems unfortunate so I looked 
at the code a bit.  I don't see an easy way to change it.

Maybe some of bonding.h should be moved into a new file
like 'include/net/bonding.h' or something.

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8520d55..8bc19b2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4395,8 +4395,7 @@ static int clip_add(struct net_device *event_dev, struct inet6_ifaddr *ifa,
 	if (cxgb4_netdev(event_dev)) {
 		switch (event) {
 		case NETDEV_UP:
-			ret = cxgb4_clip_get(event_dev,
-				(const struct in6_addr *)ifa->addr.s6_addr);
+			ret = cxgb4_clip_get(event_dev, &ifa->addr);
 			if (ret < 0) {
 				rcu_read_unlock();
 				return ret;
@@ -4404,8 +4403,7 @@ static int clip_add(struct net_device *event_dev, struct inet6_ifaddr *ifa,
 			ret = NOTIFY_OK;
 			break;
 		case NETDEV_DOWN:
-			cxgb4_clip_release(event_dev,
-				(const struct in6_addr *)ifa->addr.s6_addr);
+			cxgb4_clip_release(event_dev, &ifa->addr);
 			ret = NOTIFY_OK;
 			break;
 		default:
@@ -4474,8 +4472,7 @@ static int update_dev_clip(struct net_device *root_dev, struct net_device *dev)
 
 	read_lock_bh(&idev->lock);
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-		ret = cxgb4_clip_get(dev,
-				(const struct in6_addr *)ifa->addr.s6_addr);
+		ret = cxgb4_clip_get(dev, &ifa->addr);
 		if (ret < 0)
 			break;
 	}
