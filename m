From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] [PATCH] netiucv: reinsert dev_alloc_name for device naming
Date: Tue, 15 Nov 2011 13:31:14 +0100
Message-ID: <20111115123152.472050433@de.ibm.com>
References: <20111115123111.128739986@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:55660 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab1KOMbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 07:31:55 -0500
Content-Disposition: inline; filename=621-netiucv-dev-alloc-name.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Invocation of dev_alloc_name() is re-inserted, because the created
net_device name is used to create the device name for the iucv bus.
This device is created before the register_netdev call.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/netiucv.c |    2 ++
 1 file changed, 2 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/netiucv.c linux-2.6-patched/drivers/s390/net/netiucv.c
--- linux-2.6/drivers/s390/net/netiucv.c	2011-10-24 09:10:05.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/netiucv.c	2011-11-14 18:27:17.000000000 +0100
@@ -1994,6 +1994,8 @@ static struct net_device *netiucv_init_n
 			   netiucv_setup_netdevice);
 	if (!dev)
 		return NULL;
+	if (dev_alloc_name(dev, dev->name) < 0)
+		goto out_netdev;
 
 	privptr = netdev_priv(dev);
 	privptr->fsm = init_fsm("netiucvdev", dev_state_names,
