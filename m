From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/5] Drop ARPHRD_IEEE802154_PHY
Date: Thu, 20 Aug 2009 20:13:07 +0400
Message-ID: <1250784787-30590-6-git-send-email-dbaryshkov@gmail.com>
References: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-2-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-3-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-4-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-5-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1250784787-30590-5-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

There are not maste devices in mac802154 anymore, so drop
ARPHRD_IEEE802154_PHY definition.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/if_arp.h         |    1 -
 net/core/dev.c                 |    4 ++--
 net/ieee802154/af_ieee802154.c |    4 +---
 net/ieee802154/raw.c           |    3 +--
 4 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index b554300..282eb37 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -87,7 +87,6 @@
 #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  */
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header */
 #define ARPHRD_IEEE802154	  804
-#define ARPHRD_IEEE802154_PHY	  805
 
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
diff --git a/net/core/dev.c b/net/core/dev.c
index 09fb03f..4b83789 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -269,7 +269,7 @@ static const unsigned short netdev_lock_type[] =
 	 ARPHRD_IRDA, ARPHRD_FCPP, ARPHRD_FCAL, ARPHRD_FCPL,
 	 ARPHRD_FCFABRIC, ARPHRD_IEEE802_TR, ARPHRD_IEEE80211,
 	 ARPHRD_IEEE80211_PRISM, ARPHRD_IEEE80211_RADIOTAP, ARPHRD_PHONET,
-	 ARPHRD_PHONET_PIPE, ARPHRD_IEEE802154, ARPHRD_IEEE802154_PHY,
+	 ARPHRD_PHONET_PIPE, ARPHRD_IEEE802154,
 	 ARPHRD_VOID, ARPHRD_NONE};
 
 static const char *const netdev_lock_name[] =
@@ -287,7 +287,7 @@ static const char *const netdev_lock_name[] =
 	 "_xmit_IRDA", "_xmit_FCPP", "_xmit_FCAL", "_xmit_FCPL",
 	 "_xmit_FCFABRIC", "_xmit_IEEE802_TR", "_xmit_IEEE80211",
 	 "_xmit_IEEE80211_PRISM", "_xmit_IEEE80211_RADIOTAP", "_xmit_PHONET",
-	 "_xmit_PHONET_PIPE", "_xmit_IEEE802154", "_xmit_IEEE802154_PHY",
+	 "_xmit_PHONET_PIPE", "_xmit_IEEE802154",
 	 "_xmit_VOID", "_xmit_NONE"};
 
 static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index d504c34..cd949d5 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -147,9 +147,7 @@ static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg,
 	dev_load(sock_net(sk), ifr.ifr_name);
 	dev = dev_get_by_name(sock_net(sk), ifr.ifr_name);
 
-	if ((dev->type == ARPHRD_IEEE802154 ||
-	     dev->type == ARPHRD_IEEE802154_PHY) &&
-	    dev->netdev_ops->ndo_do_ioctl)
+	if (dev->type == ARPHRD_IEEE802154 && dev->netdev_ops->ndo_do_ioctl)
 		ret = dev->netdev_ops->ndo_do_ioctl(dev, &ifr, cmd);
 
 	if (!ret && copy_to_user(arg, &ifr, sizeof(struct ifreq)))
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 60dee69..4681501 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -74,8 +74,7 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int len)
 		goto out;
 	}
 
-	if (dev->type != ARPHRD_IEEE802154_PHY &&
-	    dev->type != ARPHRD_IEEE802154) {
+	if (dev->type != ARPHRD_IEEE802154) {
 		err = -ENODEV;
 		goto out_put;
 	}
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
