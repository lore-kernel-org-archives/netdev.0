From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: unset primary slave via sysfs
Date: Tue, 29 Jan 2013 12:54:52 +0100
Message-ID: <20130129115452.GB7571@minipsycho.orion>
References: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: Milos Vyletel <milos.vyletel@sde.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:45139 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab3A2LzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 06:55:01 -0500
Received: by mail-wg0-f49.google.com with SMTP id 15so239632wgd.16
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 03:54:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 28, 2013 at 06:20:52PM CET, milos.vyletel@sde.cz wrote:
>When bonding module is loaded with primary parameter and one decides to unset
>primary slave using sysfs these settings are not preserved during bond device
>restart. Primary slave is only unset once and it's not remembered in
>bond->params structure.
>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>


>Signed-off-by: Milos Vyletel <milos.vyletel@sde.cz>
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
