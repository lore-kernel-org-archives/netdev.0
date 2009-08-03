From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/5] af_ieee802154: provide dummy
	get/setsockopt
Date: Tue,  4 Aug 2009 03:11:41 +0400
Message-ID: <1249341101-11593-4-git-send-email-dbaryshkov@gmail.com>
References: <1249339902-10613-2-git-send-email-dbaryshkov@gmail.com>
	<1249341101-11593-1-git-send-email-dbaryshkov@gmail.com>
	<1249341101-11593-2-git-send-email-dbaryshkov@gmail.com>
	<1249341101-11593-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1249341101-11593-3-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Provide dummt get/setsockopt implementations to stop these
syscalls from oopsing on our sockets.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/dgram.c |   14 ++++++++++++++
 net/ieee802154/raw.c   |   14 ++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 53dd912..d1da6c6 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -377,6 +377,18 @@ int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
 	return ret;
 }
 
+static int dgram_getsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, int __user *optlen)
+{
+	return -EOPNOTSUPP;
+}
+
+static int dgram_setsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, int __user optlen)
+{
+	return -EOPNOTSUPP;
+}
+
 struct proto ieee802154_dgram_prot = {
 	.name		= "IEEE-802.15.4-MAC",
 	.owner		= THIS_MODULE,
@@ -391,5 +403,7 @@ struct proto ieee802154_dgram_prot = {
 	.connect	= dgram_connect,
 	.disconnect	= dgram_disconnect,
 	.ioctl		= dgram_ioctl,
+	.getsockopt	= dgram_getsockopt,
+	.setsockopt	= dgram_setsockopt,
 };
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index ea8d1f1..60dee69 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -238,6 +238,18 @@ void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb)
 	read_unlock(&raw_lock);
 }
 
+static int raw_getsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, int __user *optlen)
+{
+	return -EOPNOTSUPP;
+}
+
+static int raw_setsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, int __user optlen)
+{
+	return -EOPNOTSUPP;
+}
+
 struct proto ieee802154_raw_prot = {
 	.name		= "IEEE-802.15.4-RAW",
 	.owner		= THIS_MODULE,
@@ -250,5 +262,7 @@ struct proto ieee802154_raw_prot = {
 	.unhash		= raw_unhash,
 	.connect	= raw_connect,
 	.disconnect	= raw_disconnect,
+	.getsockopt	= raw_getsockopt,
+	.setsockopt	= raw_setsockopt,
 };
 
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
