From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 2/3] af_ieee802154: provide dummy get/setsockopt
Date: Wed,  5 Aug 2009 11:28:16 +0400
Message-ID: <1249457297-8355-3-git-send-email-dbaryshkov@gmail.com>
References: <1249457297-8355-1-git-send-email-dbaryshkov@gmail.com>
 <1249457297-8355-2-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:39992 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933668AbZHEH2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 03:28:52 -0400
Received: by fg-out-1718.google.com with SMTP id e12so819624fga.17
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 00:28:52 -0700 (PDT)
In-Reply-To: <1249457297-8355-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide dummt get/setsockopt implementations to stop these
syscalls from oopsing on our sockets.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
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

