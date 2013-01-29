From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: unset primary slave via sysfs
Date: Tue, 29 Jan 2013 10:35:40 -0800
Message-ID: <31224.1359484540@death.nxdomain>
References: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Milos Vyletel <milos.vyletel@sde.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:58705 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab3A2SgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:36:03 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 29 Jan 2013 11:36:02 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9D87519D803E
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 11:35:59 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0TIZr76327204
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 11:35:54 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0TIZjeq026555
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 11:35:52 -0700
In-reply-to: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Milos Vyletel <milos.vyletel@sde.cz> wrote:

>When bonding module is loaded with primary parameter and one decides to unset
>primary slave using sysfs these settings are not preserved during bond device
>restart. Primary slave is only unset once and it's not remembered in
>bond->params structure.
>
>Signed-off-by: Milos Vyletel <milos.vyletel@sde.cz>

	I think the patch is fine, although I did prefer the longer
commit message from the initial version (the one that explained how to
reproduce the problem).

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>---
> drivers/net/bonding/bond_sysfs.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index ef8d2a0..155f3b4 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1067,6 +1067,7 @@ static ssize_t bonding_store_primary(struct device *d,
> 		pr_info("%s: Setting primary slave to None.\n",
> 			bond->dev->name);
> 		bond->primary_slave = NULL;
>+		memset(bond->params.primary, 0, sizeof(bond->params.primary));
> 		bond_select_active_slave(bond);
> 		goto out;
> 	}
>-- 
>1.7.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
