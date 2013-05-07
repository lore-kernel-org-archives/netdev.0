From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net/irda: fix error return code in bfin_sir_open()
Date: Tue, 7 May 2013 20:14:33 +0800
Message-ID: <CAPgLHd_MWMBjPhhd=md5AH2kG0=tnPc_9Ka44cA7zD4a3R5k2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:63285 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757184Ab3EGMOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 08:14:35 -0400
Received: by mail-bk0-f41.google.com with SMTP id jc3so249462bkc.14
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 05:14:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -ENOMEM in the irlap_open() error handling case instead
of 0(overwrite to 0 by bfin_sir_startup()), as done elsewhere in this
function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/irda/bfin_sir.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index a06fca6..22b4527 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -609,7 +609,7 @@ static int bfin_sir_open(struct net_device *dev)
 {
 	struct bfin_sir_self *self = netdev_priv(dev);
 	struct bfin_sir_port *port = self->sir_port;
-	int err = -ENOMEM;
+	int err;
 
 	self->newspeed = 0;
 	self->speed = 9600;
@@ -623,8 +623,10 @@ static int bfin_sir_open(struct net_device *dev)
 	bfin_sir_set_speed(port, 9600);
 
 	self->irlap = irlap_open(dev, &self->qos, DRIVER_NAME);
-	if (!self->irlap)
+	if (!self->irlap) {
+		err = -ENOMEM;
 		goto err_irlap;
+	}
 
 	INIT_WORK(&self->work, bfin_sir_send_work);
 
