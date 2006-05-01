From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH 1/5] orinoco: unregister network device before releasing PCMCIA resources
Date: Mon, 01 May 2006 02:13:24 -0400
Message-ID: <20060501061324.13342.58195.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:56800 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751275AbWEAGN0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 02:13:26 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FaRev-0007Fp-A5
	for netdev@vger.kernel.org; Mon, 01 May 2006 02:13:25 -0400
To: netdev@vger.kernel.org, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

Hardware resources should not be made available to other devices while
the network device is still registered.  Also remove the related debug
statements.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/orinoco_cs.c  |    9 +++------
 drivers/net/wireless/spectrum_cs.c |    9 +++------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index d2c48ac..ee05ec6 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -147,14 +147,11 @@ static void orinoco_cs_detach(struct pcm
 {
 	struct net_device *dev = link->priv;
 
+	if (link->dev_node)
+		unregister_netdev(dev);
+
 	orinoco_cs_release(link);
 
-	DEBUG(0, PFX "detach: link=%p link->dev_node=%p\n", link, link->dev_node);
-	if (link->dev_node) {
-		DEBUG(0, PFX "About to unregister net device %p\n",
-		      dev);
-		unregister_netdev(dev);
-	}
 	free_orinocodev(dev);
 }				/* orinoco_cs_detach */
 
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index aeb38d9..0921162 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -625,14 +625,11 @@ static void spectrum_cs_detach(struct pc
 {
 	struct net_device *dev = link->priv;
 
+	if (link->dev_node)
+		unregister_netdev(dev);
+
 	spectrum_cs_release(link);
 
-	DEBUG(0, PFX "detach: link=%p link->dev_node=%p\n", link, link->dev_node);
-	if (link->dev_node) {
-		DEBUG(0, PFX "About to unregister net device %p\n",
-		      dev);
-		unregister_netdev(dev);
-	}
 	free_orinocodev(dev);
 }				/* spectrum_cs_detach */
 

