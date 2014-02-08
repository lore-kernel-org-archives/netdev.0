From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 04/13] net: Mark functions as static in core/dev.c
Date: Sun, 9 Feb 2014 01:23:45 +0530
Message-ID: <ccd9586270a8ebb87aeadc10feff52857b7f907c.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: josh@joshtriplett.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Pravin B Shelar <pshelar@nicira.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark functions as static in core/dev.c because they are not used outsid=
e
this file.

This eliminates the following warning in core/dev.c:
net/core/dev.c:2806:5: warning: no previous prototype for =E2=80=98__de=
v_queue_xmit=E2=80=99 [-Wmissing-prototypes]
net/core/dev.c:4640:5: warning: no previous prototype for =E2=80=98netd=
ev_adjacent_sysfs_add=E2=80=99 [-Wmissing-prototypes]
net/core/dev.c:4650:6: warning: no previous prototype for =E2=80=98netd=
ev_adjacent_sysfs_del=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 net/core/dev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3721db7..4ad1b78 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2803,7 +2803,7 @@ EXPORT_SYMBOL(dev_loopback_xmit);
  *      the BH enable code must have IRQs enabled so that it will not =
deadlock.
  *          --BLG
  */
-int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
+static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 {
 	struct net_device *dev =3D skb->dev;
 	struct netdev_queue *txq;
@@ -4637,7 +4637,7 @@ struct net_device *netdev_master_upper_dev_get_rc=
u(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
=20
-int netdev_adjacent_sysfs_add(struct net_device *dev,
+static int netdev_adjacent_sysfs_add(struct net_device *dev,
 			      struct net_device *adj_dev,
 			      struct list_head *dev_list)
 {
@@ -4647,7 +4647,7 @@ int netdev_adjacent_sysfs_add(struct net_device *=
dev,
 	return sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj),
 				 linkname);
 }
-void netdev_adjacent_sysfs_del(struct net_device *dev,
+static void netdev_adjacent_sysfs_del(struct net_device *dev,
 			       char *name,
 			       struct list_head *dev_list)
 {
--=20
1.7.9.5
