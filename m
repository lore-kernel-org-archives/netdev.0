From: "Laurent Chavey" <chavey@google.com>
Subject: [PATCH 2.6.21.3] bonding: Fix 802.3ad no carrier on "no partner found" instance
Date: Fri, 1 Jun 2007 13:16:02 -0700
Message-ID: <97949e3e0706011316n5d90bb04kf3a2c556af3fbe9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:33066 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763279AbXFAUQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 16:16:15 -0400
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l51KGBuS031337
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 13:16:11 -0700
Received: from ik-out-1112.google.com (ikab32.prod.google.com [10.68.53.32])
	by zps35.corp.google.com with ESMTP id l51KFaYG020933
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 13:16:02 -0700
Received: by ik-out-1112.google.com with SMTP id b32so623285ika
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2007 13:16:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the requirement to have at least one configured partner to
enable the operation of links. The later is necessary to have the code
in compliance with section 43.3.9 of IEEE 802.3,

Signed-off-by: Laurent Chavey <chavey@google.com>
--

diff -ru linux-2.6.21.3/drivers/net/bonding/bond_3ad.c
linux-2.6.21.3.new/drivers/net/bonding/bond_3ad.c
--- linux-2.6.21.3/drivers/net/bonding/bond_3ad.c       2007-05-24
14:22:47.000000000 -0700
+++ linux-2.6.21.3.new/drivers/net/bonding/bond_3ad.c   2007-06-01
12:41:57.000000000 -0700
@@ -2303,19 +2303,17 @@
 }

 /*
- * set link state for bonding master: if we have an active partnered
+ * set link state for bonding master: if we have an active
  * aggregator, we're up, if not, we're down.  Presumes that we cannot
  * have an active aggregator if there are no slaves with link up.
+ * Code is implementing compliance with section 43.3.9 of IEEE 802.3.
  *
  * Called by bond_set_carrier(). Return zero if carrier state does not
  * change, nonzero if it does.
  */
 int bond_3ad_set_carrier(struct bonding *bond)
 {
-       struct aggregator *agg;
-
-       agg = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
-       if (agg && MAC_ADDRESS_COMPARE(&agg->partner_system, &null_mac_addr)) {
+       if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
                if (!netif_carrier_ok(bond->dev)) {
                        netif_carrier_on(bond->dev);
                        return 1;
@@ -2468,4 +2466,3 @@

        return ret;
 }
-
