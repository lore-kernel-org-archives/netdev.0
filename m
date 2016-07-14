From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2 -next] wan/fsl_ucc_hdlc: info leak in uhdlc_ioctl()
Date: Thu, 14 Jul 2016 14:16:53 +0300
Message-ID: <20160714111653.GA30452@mwanda>
References: <57876EE0.10603@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	kernel-janitors@vger.kernel.org, walter harms <wharms@bfs.de>
To: Zhao Qiang <qiang.zhao@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46671 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbcGNLRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 07:17:21 -0400
Content-Disposition: inline
In-Reply-To: <57876EE0.10603@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a 2 byte struct whole after line.loopback so we need to clear
that out to avoid disclosing stack information.

Fixes: c19b6d246a35 ('drivers/net: support hdlc function for QE-UCC')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: remove the other initialization to zero

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 19174ac..6edd48a 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -635,9 +635,8 @@ static int uhdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			ifr->ifr_settings.size = size; /* data size wanted */
 			return -ENOBUFS;
 		}
+		memset(&line, 0, sizeof(line));
 		line.clock_type = priv->clocking;
-		line.clock_rate = 0;
-		line.loopback = 0;
 
 		if (copy_to_user(ifr->ifr_settings.ifs_ifsu.sync, &line, size))
 			return -EFAULT;
