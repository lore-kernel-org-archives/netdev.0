From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: type bug in isdn_net_header()
Date: Thu, 9 Feb 2012 13:46:47 +0300
Message-ID: <20120209104647.GB5540@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:38063 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab2BIKr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 05:47:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use len to store the return value from eth_header().  eth_header()
can return -ETH_HLEN (-14).  We want to pass this back instead of
truncating it to 65522 and returning that.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
WARNING: Compile tested only.  I don't have this hardware.  Please check
that I am on the right track.

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 2339d73..802ab87 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1901,7 +1901,7 @@ static int isdn_net_header(struct sk_buff *skb, struct net_device *dev,
 {
 	isdn_net_local *lp = netdev_priv(dev);
 	unsigned char *p;
-	ushort len = 0;
+	int len = 0;
 
 	switch (lp->p_encap) {
 		case ISDN_NET_ENCAP_ETHER:
