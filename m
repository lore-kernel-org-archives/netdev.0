From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 4/6] gianfar: Fix thinko in gfar_set_rx_stash_index()
Date: Wed, 11 Nov 2009 03:11:07 +0300
Message-ID: <20091111001107.GD8817@oksana.dev.rtsoft.ru>
References: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>, Jon Loeliger <jdl@jdl.com>,
	Kumar Gopalpet-B05799 <B05799@freescale.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:1573 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752017AbZKKALB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 19:11:01 -0500
Content-Disposition: inline
In-Reply-To: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We obviously want to write a modified 'temp' value back to the
register, not the saved IRQ flags.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar_sysfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 3724835..b31c9c8 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -186,7 +186,7 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 	temp = gfar_read(&regs->attreli);
 	temp &= ~ATTRELI_EI_MASK;
 	temp |= ATTRELI_EI(index);
-	gfar_write(&regs->attreli, flags);
+	gfar_write(&regs->attreli, temp);
 
 out:
 	unlock_rx_qs(priv);
-- 
1.6.3.3

