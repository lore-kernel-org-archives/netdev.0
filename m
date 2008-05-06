From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/4] qla3xxx: Hold RTNL while calling dev_close()
Date: Tue, 6 May 2008 19:36:26 +0100
Message-ID: <20080506183626.GH2217@solarflare.com>
References: <20080506182654.GF2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Ron Mercer <linux-driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54034 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755040AbYEFShM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 14:37:12 -0400
Content-Disposition: inline
In-Reply-To: <20080506182654.GF2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_close() must be called holding the RTNL.  Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/qla3xxx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index b7f7b22..bccee68 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3701,7 +3701,9 @@ static int ql_cycle_adapter(struct ql3_adapter *qdev, int reset)
 		printk(KERN_ERR PFX
 				"%s: Driver up/down cycle failed, "
 				"closing device\n",qdev->ndev->name);
+		rtnl_lock();
 		dev_close(qdev->ndev);
+		rtnl_unlock();
 		return -1;
 	}
 	return 0;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
