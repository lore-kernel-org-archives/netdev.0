From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] chelsio: use kzalloc
Date: Fri, 17 Nov 2006 17:01:52 -0800
Message-ID: <20061117170152.7ec3447c@zqx3.pdx.osdl.net>
References: <20061117112523.399e4122@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:13478 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1756113AbWKRBCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 20:02:14 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061117112523.399e4122@zqx3.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kzalloc() in chelsio driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- chelsio-t2.orig/drivers/net/chelsio/sge.c
+++ chelsio-t2/drivers/net/chelsio/sge.c
@@ -335,10 +335,9 @@ static int alloc_rx_resources(struct sge
 			goto err_no_mem;
 		memset(q->entries, 0, size);
 		size = sizeof(struct freelQ_ce) * q->size;
-		q->centries = kmalloc(size, GFP_KERNEL);
+		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
 			goto err_no_mem;
-		memset(q->centries, 0, size);
 	}
 
 	/*
@@ -463,10 +462,9 @@ static int alloc_tx_resources(struct sge
 			goto err_no_mem;
 		memset(q->entries, 0, size);
 		size = sizeof(struct cmdQ_ce) * q->size;
-		q->centries = kmalloc(size, GFP_KERNEL);
+		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
 			goto err_no_mem;
-		memset(q->centries, 0, size);
 	}
 
 	/*
@@ -1635,11 +1633,10 @@ static void espibug_workaround(void *dat
 struct sge * __devinit t1_sge_create(struct adapter *adapter,
 				     struct sge_params *p)
 {
-	struct sge *sge = kmalloc(sizeof(*sge), GFP_KERNEL);
+	struct sge *sge = kzalloc(sizeof(*sge), GFP_KERNEL);
 
 	if (!sge)
 		return NULL;
-	memset(sge, 0, sizeof(*sge));
 
 	sge->adapter = adapter;
 	sge->netdev = adapter->port[0].dev;

