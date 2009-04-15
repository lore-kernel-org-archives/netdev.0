From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 17/26] mipsnet: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:51 +0400
Message-ID: <1239835980-22502-17-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-13-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-14-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-15-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-16-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:53404 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756365AbZDOWxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:25 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so121391fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:24 -0700 (PDT)
In-Reply-To: <1239835980-22502-16-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/mipsnet.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 664835b..b3b9a14 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -237,6 +237,16 @@ static void mipsnet_set_mclist(struct net_device *dev)
 {
 }
 
+static const struct net_device_ops mipsnet_netdev_ops = {
+	.ndo_open		= mipsnet_open,
+	.ndo_stop		= mipsnet_close,
+	.ndo_start_xmit		= mipsnet_xmit,
+	.ndo_set_multicast_list	= mipsnet_set_mclist,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __init mipsnet_probe(struct platform_device *dev)
 {
 	struct net_device *netdev;
@@ -250,10 +260,7 @@ static int __init mipsnet_probe(struct platform_device *dev)
 
 	platform_set_drvdata(dev, netdev);
 
-	netdev->open			= mipsnet_open;
-	netdev->stop			= mipsnet_close;
-	netdev->hard_start_xmit		= mipsnet_xmit;
-	netdev->set_multicast_list	= mipsnet_set_mclist;
+	netdev->netdev_ops = &mipsnet_netdev_ops;
 
 	/*
 	 * TODO: probe for these or load them from PARAM
-- 
1.6.2.3

