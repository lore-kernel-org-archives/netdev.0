From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in he_init_group()
Date: Mon, 28 Sep 2009 10:58:43 +0200
Message-ID: <4AC07AC3.1090707@gmail.com>
References: <4AB66240.6060703@gmail.com>	<20090922.142532.24854998.davem@davemloft.net>	<4ABE152F.20507@gmail.com> <20090926.202636.105018102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:42476 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbZI1Iuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 04:50:39 -0400
Received: by ewy7 with SMTP id 7so4217433ewy.17
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 01:50:42 -0700 (PDT)
In-Reply-To: <20090926.202636.105018102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Juha Leppanen <juha_motorsportcom@luukku.com>
Date: Sat, Sep 26, 2009 at 12:34 AM
Subject: atm: he: memleak/negative indexing of arrays in he_init_group()

The prefix decrement causes a very long loop if pci_pool_alloc() failed
in the first iteration. Also I swapped rbps and rbpl arguments.

Reported-by: Juha Leppanen <juha_motorsportcom@luukku.com>
Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 29e66d6..7066703 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -921,9 +921,9 @@ out_free_rbpq_base:
 			he_dev->rbrq_phys);
 	i = CONFIG_RBPL_SIZE;
 out_free_rbpl_virt:
-	while (--i)
-		pci_pool_free(he_dev->rbps_pool, he_dev->rbpl_virt[i].virt,
-				he_dev->rbps_base[i].phys);
+	while (i--)
+		pci_pool_free(he_dev->rbpl_pool, he_dev->rbpl_virt[i].virt,
+				he_dev->rbpl_base[i].phys);
 	kfree(he_dev->rbpl_virt);
 
 out_free_rbpl_base:
@@ -933,11 +933,11 @@ out_free_rbpl_base:
 out_destroy_rbpl_pool:
 	pci_pool_destroy(he_dev->rbpl_pool);
 
-	i = CONFIG_RBPL_SIZE;
+	i = CONFIG_RBPS_SIZE;
 out_free_rbps_virt:
-	while (--i)
-		pci_pool_free(he_dev->rbpl_pool, he_dev->rbps_virt[i].virt,
-				he_dev->rbpl_base[i].phys);
+	while (i--)
+		pci_pool_free(he_dev->rbps_pool, he_dev->rbps_virt[i].virt,
+				he_dev->rbps_base[i].phys);
 	kfree(he_dev->rbps_virt);
 
 out_free_rbps_base:
