From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 7/15] netdevice ppp: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Tue, 26 Aug 2008 18:23:21 +0800
Message-ID: <48B3D999.30601@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64237 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753180AbYHZKZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 06:25:47 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/ppp_generic.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index ddccc07..7d41fbd 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -886,7 +886,7 @@ out_chrdev:
 static int
 ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ppp *ppp = (struct ppp *) dev->priv;
+	struct ppp *ppp = dev->ml_priv;
 	int npi, proto;
 	unsigned char *pp;
 
@@ -931,7 +931,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int
 ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct ppp *ppp = dev->priv;
+	struct ppp *ppp = dev->ml_priv;
 	int err = -EFAULT;
 	void __user *addr = (void __user *) ifr->ifr_ifru.ifru_data;
 	struct ppp_stats stats;
@@ -2435,7 +2435,7 @@ ppp_create_interface(int unit, int *retp)
 	skb_queue_head_init(&ppp->mrq);
 #endif /* CONFIG_PPP_MULTILINK */
 	ppp->dev = dev;
-	dev->priv = ppp;
+	dev->ml_priv = ppp;
 
 	dev->hard_start_xmit = ppp_start_xmit;
 	dev->do_ioctl = ppp_net_ioctl;
-- 
1.5.3.4

