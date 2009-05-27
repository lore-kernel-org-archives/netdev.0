From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: use bond_is_lb() when it's appropriate
Date: Wed, 27 May 2009 09:13:42 -0700
Message-ID: <2419.1243440822@death.nxdomain.ibm.com>
References: <20090527154235.GA17121@psychotron.englab.brq.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:47709 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbZE0QNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 12:13:35 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4RG76or027491
	for <netdev@vger.kernel.org>; Wed, 27 May 2009 10:07:07 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4RGDbkM163008
	for <netdev@vger.kernel.org>; Wed, 27 May 2009 10:13:37 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4RGDauQ012683
	for <netdev@vger.kernel.org>; Wed, 27 May 2009 10:13:36 -0600
In-reply-to: <20090527154235.GA17121@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>[PATCH] bonding: use bond_is_lb() when it's appropriate
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>

	Looks good.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 7482402..3ec7d52 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2399,8 +2399,7 @@ static void bond_miimon_commit(struct bonding *bond)
> 				bond_3ad_handle_link_change(slave,
> 							    BOND_LINK_DOWN);
>
>-			if (bond->params.mode == BOND_MODE_TLB ||
>-			    bond->params.mode == BOND_MODE_ALB)
>+			if (bond_is_lb(bond))
> 				bond_alb_handle_link_change(bond, slave,
> 							    BOND_LINK_DOWN);
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index ca849d2..41ceca1 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -286,8 +286,7 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
> static inline void bond_set_slave_inactive_flags(struct slave *slave)
> {
> 	struct bonding *bond = netdev_priv(slave->dev->master);
>-	if (bond->params.mode != BOND_MODE_TLB &&
>-	    bond->params.mode != BOND_MODE_ALB)
>+	if (!bond_is_lb(bond))
> 		slave->state = BOND_STATE_BACKUP;
> 	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
> 	if (slave_do_arp_validate(bond, slave))
