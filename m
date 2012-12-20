From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] solos-pci: double lock in geos_gpio_store()
Date: Thu, 20 Dec 2012 10:48:45 +0300
Message-ID: <20121220074845.GA14716@elgon.mountain>
References: <50d25b88.0QAOhrb1a/eK/hR1%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kbuild@01.org
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	Nathan Williams <nathan@traverse.com.au>,
	David Woodhouse <David.Woodhouse@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43394 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab2LTHut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 02:50:49 -0500
Content-Disposition: inline
In-Reply-To: <50d25b88.0QAOhrb1a/eK/hR1%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a typo here so we do a double lock instead of an unlock.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Only needed in linux-next.  Introduced in f9baad02e7411d9 [14/17]
solos-pci: add GPIO support for newer versions on Geos board

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 473d808..7b95736 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -531,7 +531,7 @@ static ssize_t geos_gpio_store(struct device *dev, struct device_attribute *attr
 	} else {
 		count = -EINVAL;
 	}
-	spin_lock_irq(&card->param_queue_lock);
+	spin_unlock_irq(&card->param_queue_lock);
 	return count;
 }
 
