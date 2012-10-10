From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 12:42:18 +0300
Message-ID: <20121010093816.GA3669@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:50359 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab2JJJmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 05:42:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"protos" is an array of unsigned longs and "i" is the number of bits in
an unsigned long so we need to use 1UL as well to prevent the shift
from wrapping around.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index a1e7601..69b5b58 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -595,7 +595,7 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 			j = ipc->num / (sizeof(long) * 8);
 			i = ipc->num % (sizeof(long) * 8);
 			if (j < 8)
-				protos[j] |= (0x1 << i);
+				protos[j] |= (1UL << i);
 			ipc = ipc->next;
 		}
 		if ((r = set_arg(argp, protos, 8 * sizeof(long))))
