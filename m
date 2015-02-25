From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/2] rocker: add a check for NULL in rocker_probe_ports()
Date: Wed, 25 Feb 2015 16:35:32 +0300
Message-ID: <20150225133532.GU19745@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48692 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbbBYNfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 08:35:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure kmalloc() succeeds.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 34389b6a..713a13c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4201,6 +4201,8 @@ static int rocker_probe_ports(struct rocker *rocker)
 
 	alloc_size = sizeof(struct rocker_port *) * rocker->port_count;
 	rocker->ports = kmalloc(alloc_size, GFP_KERNEL);
+	if (!rocker->ports)
+		return -ENOMEM;
 	for (i = 0; i < rocker->port_count; i++) {
 		err = rocker_probe_port(rocker, i);
 		if (err)
