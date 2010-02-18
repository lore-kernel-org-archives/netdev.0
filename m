From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] tokenring: convert to use
 netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 13:47:07 +0100
Message-ID: <20100218124706.GG2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757860Ab0BRMrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 07:47:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/tokenring/3c359.c       |    5 ++---
 drivers/net/tokenring/ibmtr.c       |    4 +---
 drivers/net/tokenring/lanstreamer.c |    4 +---
 drivers/net/tokenring/olympic.c     |    5 ++---
 drivers/net/tokenring/tms380tr.c    |    8 +++-----
 5 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index eff68e1..0fb930f 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1390,10 +1390,9 @@ static int xl_close(struct net_device *dev)
 static void xl_set_rx_mode(struct net_device *dev) 
 {
 	struct xl_private *xl_priv = netdev_priv(dev);
-	struct dev_mc_list *dmi ; 
+	struct dev_mc_list *dmi;
 	unsigned char dev_mc_address[4] ; 
 	u16 options ; 
-	int i ; 
 
 	if (dev->flags & IFF_PROMISC)
 		options = 0x0004 ; 
@@ -1408,7 +1407,7 @@ static void xl_set_rx_mode(struct net_device *dev)
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ;
 
-        for (i=0,dmi=dev->mc_list;i < netdev_mc_count(dev); i++,dmi = dmi->next) {
+	netdev_for_each_mc_addr(dmi, dev) {
                 dev_mc_address[0] |= dmi->dmi_addr[2] ;
                 dev_mc_address[1] |= dmi->dmi_addr[3] ;
                 dev_mc_address[2] |= dmi->dmi_addr[4] ;
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 1ce8f85..1a09672 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -995,13 +995,11 @@ static void tok_set_multicast_list(struct net_device *dev)
 	/*BMS ifconfig tr down or hot unplug a PCMCIA card ??hownowbrowncow*/
 	if (/*BMSHELPdev->start == 0 ||*/ ti->open_status != OPEN) return;
 	address[0] = address[1] = address[2] = address[3] = 0;
-	mclist = dev->mc_list;
-	for (i = 0; i < netdev_mc_count(dev); i++) {
+	netdev_for_each_mc_addr(mclist, dev) {
 		address[0] |= mclist->dmi_addr[2];
 		address[1] |= mclist->dmi_addr[3];
 		address[2] |= mclist->dmi_addr[4];
 		address[3] |= mclist->dmi_addr[5];
-		mclist = mclist->next;
 	}
 	SET_PAGE(ti->srb_page);
 	for (i = 0; i < sizeof(struct srb_set_funct_addr); i++)
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 26d84da..dd028fe 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1268,7 +1268,6 @@ static void streamer_set_rx_mode(struct net_device *dev)
 	__u8 options = 0;
 	struct dev_mc_list *dmi;
 	unsigned char dev_mc_address[5];
-	int i;
 
 	writel(streamer_priv->srb, streamer_mmio + LAPA);
 	options = streamer_priv->streamer_copy_all_options;
@@ -1303,8 +1302,7 @@ static void streamer_set_rx_mode(struct net_device *dev)
 	writel(streamer_priv->srb,streamer_mmio+LAPA);
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
   
-	for (i=0,dmi=dev->mc_list;i < netdev_mc_count(dev); i++,dmi = dmi->next)
-	{ 
+	netdev_for_each_mc_addr(dmi, dev) {
    	        dev_mc_address[0] |= dmi->dmi_addr[2] ; 
 		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
 		dev_mc_address[2] |= dmi->dmi_addr[4] ; 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index a242d12..3a25e04 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1139,9 +1139,8 @@ static void olympic_set_rx_mode(struct net_device *dev)
    	u8 __iomem *olympic_mmio = olympic_priv->olympic_mmio ; 
 	u8 options = 0; 
 	u8 __iomem *srb;
-	struct dev_mc_list *dmi ; 
+	struct dev_mc_list *dmi;
 	unsigned char dev_mc_address[4] ; 
-	int i ; 
 
 	writel(olympic_priv->srb,olympic_mmio+LAPA);
 	srb=olympic_priv->olympic_lap + (olympic_priv->srb & (~0xf800));
@@ -1178,7 +1177,7 @@ static void olympic_set_rx_mode(struct net_device *dev)
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
 
-	for (i=0,dmi=dev->mc_list;i < netdev_mc_count(dev); i++,dmi = dmi->next) {
+	netdev_for_each_mc_addr(dmi, dev) {
 		dev_mc_address[0] |= dmi->dmi_addr[2] ; 
 		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
 		dev_mc_address[2] |= dmi->dmi_addr[4] ; 
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index 6b88689..21a0175 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1212,10 +1212,9 @@ static void tms380tr_set_multicast_list(struct net_device *dev)
 		}
 		else
 		{
-			int i;
-			struct dev_mc_list *mclist = dev->mc_list;
-			for (i=0; i< netdev_mc_count(dev); i++)
-			{
+			struct dev_mc_list *mclist;
+
+			netdev_for_each_mc_addr(mclist, dev) {
 				((char *)(&tp->ocpl.FunctAddr))[0] |=
 					mclist->dmi_addr[2];
 				((char *)(&tp->ocpl.FunctAddr))[1] |=
@@ -1224,7 +1223,6 @@ static void tms380tr_set_multicast_list(struct net_device *dev)
 					mclist->dmi_addr[4];
 				((char *)(&tp->ocpl.FunctAddr))[3] |=
 					mclist->dmi_addr[5];
-				mclist = mclist->next;
 			}
 		}
 		tms380tr_exec_cmd(dev, OC_SET_FUNCT_ADDR);
-- 
1.6.6

