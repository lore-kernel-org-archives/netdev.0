From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/16] net: remove usage of dev->master
Date: Mon, 13 Aug 2012 17:27:14 +0200
Message-ID: <1344871635-1052-16-git-send-email-jiri@resnulli.us>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c0f9adb..8977404 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5461,8 +5461,8 @@ static void rollback_registered_many(struct list_head *head)
 		if (dev->netdev_ops->ndo_uninit)
 			dev->netdev_ops->ndo_uninit(dev);
 
-		/* Notifier chain MUST detach us from master device. */
-		WARN_ON(dev->master);
+		/* Notifier chain MUST detach us all upper devices. */
+		WARN_ON(netdev_has_any_upper_dev(dev));
 
 		/* Remove entries from kobject tree */
 		netdev_unregister_kobject(dev);
-- 
1.7.10.4
