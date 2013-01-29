From: Milos Vyletel <milos.vyletel@sde.cz>
Subject: Re: [PATCH] bonding: unset primary slave via sysfs
Date: Tue, 29 Jan 2013 20:20:43 +0100 (CET)
Message-ID: <269c3219-71dc-4802-81a4-562e61a1258c@zimbra>
References: <31224.1359484540@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sde.cz ([85.93.125.197]:44140 "EHLO sde.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751392Ab3A2TUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:20:47 -0500
In-Reply-To: <31224.1359484540@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> Milos Vyletel <milos.vyletel@sde.cz> wrote:
> 
> >When bonding module is loaded with primary parameter and one decides
> >to unset
> >primary slave using sysfs these settings are not preserved during
> >bond device
> >restart. Primary slave is only unset once and it's not remembered in
> >bond->params structure.
> >
> >Signed-off-by: Milos Vyletel <milos.vyletel@sde.cz>
> 
> 	I think the patch is fine, although I did prefer the longer
> commit message from the initial version (the one that explained how
> to
> reproduce the problem).
> 
> 	-J
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 

Jay,

just to be sure, do you want me to resend this patch again with the
original commit message? It's no problem for me, I just don't want
to spam this list when not necessary.

Milos

> 
> >---
> > drivers/net/bonding/bond_sysfs.c |    1 +
> > 1 files changed, 1 insertions(+), 0 deletions(-)
> >
> >diff --git a/drivers/net/bonding/bond_sysfs.c
> >b/drivers/net/bonding/bond_sysfs.c
> >index ef8d2a0..155f3b4 100644
> >--- a/drivers/net/bonding/bond_sysfs.c
> >+++ b/drivers/net/bonding/bond_sysfs.c
> >@@ -1067,6 +1067,7 @@ static ssize_t bonding_store_primary(struct
> >device *d,
> > 		pr_info("%s: Setting primary slave to None.\n",
> > 			bond->dev->name);
> > 		bond->primary_slave = NULL;
> >+		memset(bond->params.primary, 0, sizeof(bond->params.primary));
> > 		bond_select_active_slave(bond);
> > 		goto out;
> > 	}
> >--
> >1.7.1
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
