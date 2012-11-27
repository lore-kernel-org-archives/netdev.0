From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] atm: forever loop loading ambassador firmware
Date: Tue, 27 Nov 2012 20:29:35 +0300
Message-ID: <20121127172935.GB1059@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19775 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117Ab2K0Rb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 12:31:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a forever loop introduced here when we converted this to
request_firmware() back in 2008.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Spotted in code reading.  Untested.

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 89b30f3..ff7bb8a 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -1961,6 +1961,7 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
     res = loader_verify(lb, dev, rec);
     if (res)
       break;
+    rec = ihex_next_binrec(rec);
   }
   release_firmware(fw);
   if (!res)
