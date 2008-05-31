From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sky2: Hold RTNL while calling dev_close() [2nd try]
Date: Sat, 31 May 2008 16:52:52 +0100
Message-ID: <20080531155251.GM1743@solarflare.com>
References: <20080506182654.GF2217@solarflare.com> <20080506183958.GI2217@solarflare.com> <20080506161720.6475e5d4@extreme> <20080506235937.GK2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:37151 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752915AbYEaPxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 11:53:32 -0400
Content-Disposition: inline
In-Reply-To: <20080506235937.GK2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_close() must be called holding the RTNL.  Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sky2.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index f226bca..b9bdf88 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4395,7 +4395,9 @@ static int sky2_resume(struct pci_dev *pdev)
 			if (err) {
 				printk(KERN_ERR PFX "%s: could not up: %d\n",
 				       dev->name, err);
+				rtnl_lock();
 				dev_close(dev);
+				rtnl_unlock();
 				goto out;
 			}
 		}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
