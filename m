From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 5/7] drivers/atm/eni.c: ensure arguments to request_irq
 and free_irq are compatible
Date: Sun, 11 Mar 2012 22:16:25 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1203112215250.1958@localhost6.localdomain6>
References: <201203112058.q2BKwBCS024617@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:29524 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751412Ab2CKVQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 17:16:28 -0400
In-Reply-To: <201203112058.q2BKwBCS024617@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert calls to free_irq so that the second argument is the same as the
last argument of the corresponding call to request_irq.  Without this
property, free_irq does nothing.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Version 2: change free_irq, not request_irq.

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 956e9ac..485a11a 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1873,7 +1873,7 @@ free_list:
  	kfree(eni_dev->free_list);

  free_irq:
-	free_irq(eni_dev->irq, eni_dev);
+	free_irq(eni_dev->irq, dev);

  out:
  	return error;
