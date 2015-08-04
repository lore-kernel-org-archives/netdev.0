From: sfeldma@gmail.com
Subject: [PATCH net-next 2/2] rocker: use netdev_err after register_netdev
Date: Mon,  3 Aug 2015 22:31:18 -0700
Message-ID: <1438666278-35614-2-git-send-email-sfeldma@gmail.com>
References: <1438666278-35614-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33844 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbbHDF3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:29:04 -0400
Received: by pdber20 with SMTP id er20so1470627pdb.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 22:29:04 -0700 (PDT)
In-Reply-To: <1438666278-35614-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

After successful register_netdev, we can use netdev_err rather the more
generic dev_err.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 0ab3a3b..4e8cad0 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4985,7 +4985,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	if (err) {
-		dev_err(&pdev->dev, "install ig port table failed\n");
+		netdev_err(rocker_port->dev, "install ig port table failed\n");
 		goto err_port_ig_tbl;
 	}
 
-- 
1.7.10.4
