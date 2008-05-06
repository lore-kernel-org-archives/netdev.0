From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/4] sky2: Hold RTNL while calling dev_close()
Date: Tue, 6 May 2008 19:39:58 +0100
Message-ID: <20080506183958.GI2217@solarflare.com>
References: <20080506182654.GF2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54047 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1764848AbYEFSln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 14:41:43 -0400
Content-Disposition: inline
In-Reply-To: <20080506182654.GF2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_close() must be called holding the RTNL.  Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sky2.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index f226bca..9b046dd 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2952,7 +2952,9 @@ static void sky2_restart(struct work_struct *work)
 			if (err) {
 				printk(KERN_INFO PFX "%s: could not restart %d\n",
 				       dev->name, err);
+				rtnl_lock();
 				dev_close(dev);
+				rtnl_unlock();
 			}
 		}
 	}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
