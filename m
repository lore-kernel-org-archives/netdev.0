From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] staging-slicoss: Kill directly reference of netdev->priv
Date: Fri, 05 Dec 2008 23:21:15 +0800
Message-ID: <493946EB.7000308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57303 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753238AbYLEPVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 10:21:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Compile test only.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/staging/slicoss/slicoss.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 8fa9490..0039036 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -765,8 +765,7 @@ static int slic_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 #ifdef SLIC_USER_REQUEST_DUMP_ENABLED
 	case SIOCSLICDUMPCARD:
 		{
-			struct adapter *adapter = (struct adapter *)
-							dev->priv;
+			struct adapter *adapter = netdev_priv(dev);
 			struct sliccard *card;
 
 			ASSERT(adapter);
@@ -1685,7 +1684,7 @@ static void slic_timer_ping(ulong dev)
 	struct sliccard *card;
 
 	ASSERT(dev);
-	adapter = (struct adapter *)((struct net_device *) dev)->priv;
+	adapter = netdev_priv((struct net_device *)dev);
 	ASSERT(adapter);
 	card = adapter->card;
 	ASSERT(card);
@@ -3136,7 +3135,7 @@ static void slic_timer_get_stats(ulong dev)
 	struct slic_shmem *pshmem;
 
 	ASSERT(dev);
-	adapter = (struct adapter *)((struct net_device *)dev)->priv;
+	adapter = netdev_priv((struct net_device *)dev);
 	ASSERT(adapter);
 	card = adapter->card;
 	ASSERT(card);
-- 
1.5.3.4



