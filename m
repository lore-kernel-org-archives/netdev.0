From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next-2.6] can: deny filterlist access on non-CAN interfaces
Date: Fri, 29 Jan 2010 08:41:55 +0100
Message-ID: <4B629143.6080402@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:24030 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab0A2HmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 02:42:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

are you fine with this fix or are you just waiting for Wolfgangs ACK?

As this is networklayer stuff in net/can and not in drivers/net/can you won't
get any ACK from Wolfgang, as i'm the maintainer for that ;-)

If it makes is more clearly i would suggest to name my networklayer patches with

[PATCH net-next-2.6] net/can: ...

instead of

[PATCH net-next-2.6] can: ...

in the future. Would this be ok for you?

Thanks & best regards,
Oliver


-------- Original Message --------
Subject: [PATCH net-next-2.6] can: deny filterlist access on non-CAN interfaces
Date: Tue, 26 Jan 2010 14:51:59 +0100
From: Oliver Hartkopp <socketcan@hartkopp.net>
To: David Miller <davem@davemloft.net>
CC: Linux Netdev List <netdev@vger.kernel.org>

In commit 20dd3850bcf860561496827b711fa10fecf6e787 "can: Speed up CAN frame
receiption by using ml_priv" the formerly used hlist of receiver lists for
each CAN netdevice has been replaced.

The hlist content ensured only CAN netdevices to be accessed by the
can_rx_(un)register() functions which accidently dropped away together with
the hlist receiver implementation.

This patch re-introduces the check for CAN netdevices in can_rx_(un)register().

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---

diff --git a/net/can/af_can.c b/net/can/af_can.c
index bc18b08..702be5a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -415,6 +415,9 @@ int can_rx_register(struct net_device *dev, canid_t
can_id, canid_t mask,

 	/* insert new receiver  (dev,canid,mask) -> (func,data) */

+	if (dev && dev->type != ARPHRD_CAN)
+		return -ENODEV;
+
 	r = kmem_cache_alloc(rcv_cache, GFP_KERNEL);
 	if (!r)
 		return -ENOMEM;
@@ -478,6 +481,9 @@ void can_rx_unregister(struct net_device *dev, canid_t
can_id, canid_t mask,
 	struct hlist_node *next;
 	struct dev_rcv_lists *d;

+	if (dev && dev->type != ARPHRD_CAN)
+		return;
+
 	spin_lock(&can_rcvlists_lock);

 	d = find_dev_rcv_lists(dev);



