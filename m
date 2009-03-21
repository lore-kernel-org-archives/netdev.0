From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 32/77] usbnet: convert rndis driver to use dev_get_stats
Date: Fri, 20 Mar 2009 22:35:59 -0700
Message-ID: <20090321053714.963078292@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36616 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760970AbZCUFsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:17 -0400
Content-Disposition: inline; filename=rndis.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_get_stats() handles all issues with net_device_ops

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/usb/gadget/rndis.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

--- a/drivers/usb/gadget/rndis.c	2009-03-20 12:18:22.054027493 -0700
+++ b/drivers/usb/gadget/rndis.c	2009-03-20 12:18:28.620714647 -0700
@@ -170,7 +170,7 @@ gen_ndis_query_resp (int configNr, u32 O
 	int			i, count;
 	rndis_query_cmplt_type	*resp;
 	struct net_device	*net;
-	struct net_device_stats	*stats;
+	const struct net_device_stats	*stats;
 
 	if (!r) return -ENOMEM;
 	resp = (rndis_query_cmplt_type *) r->buf;
@@ -193,10 +193,7 @@ gen_ndis_query_resp (int configNr, u32 O
 	resp->InformationBufferOffset = cpu_to_le32 (16);
 
 	net = rndis_per_dev_params[configNr].dev;
-	if (net->get_stats)
-		stats = net->get_stats(net);
-	else
-		stats = NULL;
+	stats = dev_get_stats(net);
 
 	switch (OID) {
 

-- 

