From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 22142] New: skge module doesn't work in
 2.6.37-rc1
Date: Mon, 08 Nov 2010 18:46:24 -0800 (PST)
Message-ID: <20101108.184624.71119177.davem@davemloft.net>
References: <bug-22142-10286@https.bugzilla.kernel.org/>
	<20101108154306.0f93eddb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	jtmettala@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39818
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754722Ab0KICqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 21:46:00 -0500
In-Reply-To: <20101108154306.0f93eddb.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 8 Nov 2010 15:43:06 -0800

> skge_devinit() did a nearly-NULL deref.

Fixed in net-2.6:

--------------------
skge: Remove tx queue stopping in skge_devinit()

After e6484930d7c73d324bccda7d43d131088da697b9: net: allocate tx queues in register_netdevice
It causes an Oops at skge_probe() time.

Signed-off-by: Guillaume Chazarain <guichaz@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/skge.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index bfec2e0..220e039 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3858,7 +3858,6 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 
 	/* device is off until link detection */
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	return dev;
 }
-- 
1.7.3.2

