From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] bridge: assign random address
Date: Tue, 11 Dec 2007 15:48:35 -0800
Message-ID: <20071211154835.75ace6bc@freepuppy.rosehill>
References: <bug-9545-10286@http.bugzilla.kernel.org/>
 <20071211132614.5854b0f1.akpm@linux-foundation.org>
 <20071211145243.66e1f66a@freepuppy.rosehill>
 <20071211145921.11094ab8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berrange@redhat.com, jeff@garzik.org, herbert@gondor.apana.org.au,
	rjw@sisk.pl
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40647 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752178AbXLKXvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 18:51:39 -0500
In-Reply-To: <20071211145921.11094ab8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assigning a valid random address to bridge device solves problems
when bridge device is brought up before adding real device to bridge.
When the first real device is added to the bridge, it's address
will overide the bridges random address.

Note: any device added to a bridge must already have a valid
ethernet address.
 br_add_if -> br_fdb_insert -> fdb_insert -> is_valid_ether_addr

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/bridge/br_device.c	2007-10-16 16:48:21.000000000 -0700
+++ b/net/bridge/br_device.c	2007-12-11 15:36:52.000000000 -0800
@@ -157,8 +157,7 @@ static struct ethtool_ops br_ethtool_ops
 
 void br_dev_setup(struct net_device *dev)
 {
-	memset(dev->dev_addr, 0, ETH_ALEN);
-
+	random_ether_addr(dev->dev_addr);
 	ether_setup(dev);
 
 	dev->do_ioctl = br_dev_ioctl;
