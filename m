From: frank.blaschka@de.ibm.com
Subject: [patch 8/8] [PATCH] qeth: avoid useless removal of multicast addresses
Date: Fri, 23 Jul 2010 11:15:10 +0200
Message-ID: <20100723091550.705540000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:43318 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Content-Disposition: inline; filename=619-qeth-multicast-removal.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Function qeth_l2_remove_device invokes qeth_l2_del_all_mc at the end.
This is needless, because it is already called in the offline function.
And even more this is invalid, because multicast addresses cannot be
removed in DOWN state. Thus this patch deletes invocation of
qeth_l2_del_all_mc in function qeth_l2_remove_device.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |    2 --
 1 file changed, 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2010-07-22 10:22:35.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2010-07-22 10:22:37.000000000 +0200
@@ -860,8 +860,6 @@ static void qeth_l2_remove_device(struct
 		unregister_netdev(card->dev);
 		card->dev = NULL;
 	}
-
-	qeth_l2_del_all_mc(card);
 	return;
 }
 

