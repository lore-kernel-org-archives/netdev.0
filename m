From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 15/17] gtp: rename gtp hashtable helpers
Date: Mon, 23 Jan 2017 12:57:04 +0100
Message-ID: <20170123115706.4354-16-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:47333 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751004AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gtp_hashtable helper are now olny used for the per netdevice
address hashes. Rename them to make their purpose clearer.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 019e80f..55bf098 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -618,8 +618,8 @@ static void gtp_link_setup(struct net_device *dev)
 				  sizeof(struct gtp0_header);
 }
 
-static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
-static void gtp_hashtable_free(struct gtp_dev *gtp);
+static int gtp_dev_hashtable_new(struct gtp_dev *gtp, int hsize);
+static void gtp_dev_hashtable_free(struct gtp_dev *gtp);
 static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 			    int hsize, struct nlattr *data[]);
 static void gtp_encap_disable(struct gtp_dev *gtp);
@@ -644,7 +644,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 			goto out_err;
 	}
 
-	err = gtp_hashtable_new(gtp, hashsize);
+	err = gtp_dev_hashtable_new(gtp, hashsize);
 	if (err < 0)
 		goto out_socket;
 
@@ -662,7 +662,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 	return 0;
 
 out_hashtable:
-	gtp_hashtable_free(gtp);
+	gtp_dev_hashtable_free(gtp);
 out_socket:
 	gtp_encap_disable(gtp);
 out_err:
@@ -673,7 +673,7 @@ static void gtp_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 
-	gtp_hashtable_free(gtp);
+	gtp_dev_hashtable_free(gtp);
 	if (gtp->sock0)
 		sockfd_put(gtp->sock0);
 	if (gtp->sock1u)
@@ -742,7 +742,7 @@ static struct net *gtp_genl_get_net(struct net *src_net, struct nlattr *tb[])
 	return net;
 }
 
-static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
+static int gtp_dev_hashtable_new(struct gtp_dev *gtp, int hsize)
 {
 	int i;
 
@@ -758,7 +758,7 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 	return 0;
 }
 
-static void gtp_hashtable_free(struct gtp_dev *gtp)
+static void gtp_dev_hashtable_free(struct gtp_dev *gtp)
 {
 	struct pdp_ctx *pctx;
 	int i;
-- 
2.10.2
