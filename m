From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 2/2] [POWERPC] Fix region size check in mpc5200 FEC driver
Date: Thu, 01 Nov 2007 08:22:35 -0600
Message-ID: <20071101142235.7620.36853.stgit@trillian.cg.shawcable.net>
References: <20071101142005.7620.54250.stgit@trillian.cg.shawcable.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jgarzik@pobox.com, domen.puncer@telargo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:32966 "EHLO
	pd4mo1so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbXKAOXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 10:23:32 -0400
Received: from pd4mr3so.prod.shaw.ca
 (pd4mr3so-qfe3.prod.shaw.ca [10.0.141.214]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JQT005W4ZXODB30@l-daemon> for netdev@vger.kernel.org; Thu,
 01 Nov 2007 08:22:36 -0600 (MDT)
Received: from pn2ml8so.prod.shaw.ca ([10.0.121.152])
 by pd4mr3so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05 (built Sep
 5 2006)) with ESMTP id <0JQT00JNEZXNKS50@pd4mr3so.prod.shaw.ca> for
 netdev@vger.kernel.org; Thu, 01 Nov 2007 08:22:35 -0600 (MDT)
Received: from trillian.cg.shawcable.net ([68.147.67.118])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JQT00BIJZXN4420@l-daemon> for netdev@vger.kernel.org; Thu,
 01 Nov 2007 08:22:35 -0600 (MDT)
In-reply-to: <20071101142005.7620.54250.stgit@trillian.cg.shawcable.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>

Driver shouldn't complain if the register range is larger than what
it expects.  This works around failures with some device trees.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/fec_mpc52xx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index fc1cf0b..a8a0ee2 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -879,9 +879,9 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 				"Error while parsing device node resource\n" );
 		return rv;
 	}
-	if ((mem.end - mem.start + 1) != sizeof(struct mpc52xx_fec)) {
+	if ((mem.end - mem.start + 1) < sizeof(struct mpc52xx_fec)) {
 		printk(KERN_ERR DRIVER_NAME
-			" - invalid resource size (%lx != %x), check mpc52xx_devices.c\n",
+			" - invalid resource size (%lx < %x), check mpc52xx_devices.c\n",
 			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));
 		return -EINVAL;
 	}

