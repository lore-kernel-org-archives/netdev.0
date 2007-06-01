From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.21.3] bonding: Fix 802.3ad no carrier on "no partner found" instance
Date: Fri, 01 Jun 2007 13:38:57 -0700
Message-ID: <23687.1180730337@death>
References: <97949e3e0706011316n5d90bb04kf3a2c556af3fbe9d@mail.gmail.com>
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: "Laurent Chavey" <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:35258 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764261AbXFAUjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 16:39:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l51JaZpo024931
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 15:36:35 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l51Kd0ox507754
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 16:39:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l51Kcxg5023284
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 16:39:00 -0400
In-reply-to: <97949e3e0706011316n5d90bb04kf3a2c556af3fbe9d@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Jeff, please apply wherever seems appropriate.  It is a bug fix,
but for a pretty obscure bit of standards compliance.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J


Laurent Chavey <chavey@google.com> wrote:

>Remove the requirement to have at least one configured partner to
>enable the operation of links. The later is necessary to have the code
>in compliance with section 43.3.9 of IEEE 802.3,
>
>Signed-off-by: Laurent Chavey <chavey@google.com>
>--
>
>diff -ru linux-2.6.21.3/drivers/net/bonding/bond_3ad.c
>linux-2.6.21.3.new/drivers/net/bonding/bond_3ad.c
>--- linux-2.6.21.3/drivers/net/bonding/bond_3ad.c       2007-05-24
>14:22:47.000000000 -0700
>+++ linux-2.6.21.3.new/drivers/net/bonding/bond_3ad.c   2007-06-01
>12:41:57.000000000 -0700
>@@ -2303,19 +2303,17 @@
>}
>
>/*
>- * set link state for bonding master: if we have an active partnered
>+ * set link state for bonding master: if we have an active
> * aggregator, we're up, if not, we're down.  Presumes that we cannot
> * have an active aggregator if there are no slaves with link up.
>+ * Code is implementing compliance with section 43.3.9 of IEEE 802.3.
> *
> * Called by bond_set_carrier(). Return zero if carrier state does not
> * change, nonzero if it does.
> */
>int bond_3ad_set_carrier(struct bonding *bond)
>{
>-       struct aggregator *agg;
>-
>-       agg = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
>-       if (agg && MAC_ADDRESS_COMPARE(&agg->partner_system, &null_mac_addr)) {
>+       if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
>               if (!netif_carrier_ok(bond->dev)) {
>                       netif_carrier_on(bond->dev);
>                       return 1;
>@@ -2468,4 +2466,3 @@
>
>       return ret;
>}
>-
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
