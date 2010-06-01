From: <Narendra_K@Dell.com>
Subject: Call trace related to bonding seen in 2.6.34
Date: Tue, 1 Jun 2010 23:15:22 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE612882@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <fubar@us.ibm.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:60745 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881Ab0FARzo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 13:55:44 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Call trace related to bond_mii_monitor  as described in this thread -
http://patchwork.ozlabs.org/patch/41288/ was seen on 2.6.34 kernel.
(Trace is similar to what is described in the post dated 2009-12-17
21:31:36.) The trace is seen when the network service is stopped. The
issue occurs when the network service is started and stopped in quick
succession. 

Bonding device configuration parameters are as below -

Bonding driver version:3.6.0
Mode: balance-alb (issue is also seen with active-backup mode)
Miimon=100
3 slaves with link up and one slave with link down.

Though this requires more thought and investigation, I thought this
could be a good data point. The below change to the bonding driver
seemed to make the issue go away -

drivers/net/bonding/bond_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c
b/drivers/net/bonding/bond_main.c
index 0075514..f280aaf 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2408,7 +2408,7 @@ void bond_mii_monitor(struct work_struct *work)
        }

 re_arm:
-       if (bond->params.miimon)
+       if (bond->params.miimon && !bond->kill_timers)
                queue_delayed_work(bond->wq, &bond->mii_work,
 
msecs_to_jiffies(bond->params.miimon));
 out:




Any thoughts ?


With regards,
Narendra K


