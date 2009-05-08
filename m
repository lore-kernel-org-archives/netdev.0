From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix panic if initialization fails
Date: Fri, 08 May 2009 15:10:21 -0700
Message-ID: <23965.1241820621@death.nxdomain.ibm.com>
References: <1241819351-26356-1-git-send-email-fw@strlen.de>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:54053 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbZEHWKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 18:10:18 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n48M9iOY011060
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 16:09:44 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n48MAHqt046018
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 16:10:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n48MAGR5022056
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 16:10:17 -0600
In-reply-to: <1241819351-26356-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:

>If module initialisation failed (e.g. because the bonding sysfs entry
>cannot be created), kernel panics:
> IP: [<ffffffff8024910a>] destroy_workqueue+0x2d/0x146
>Call Trace:
> [<ffffffff808268c4>] bond_destructor+0x28/0x78
> [<ffffffff80b64471>] netdev_run_todo+0x231/0x25a
> [<ffffffff80b6dbcd>] rtnl_unlock+0x9/0xb
> [<ffffffff81567907>] bonding_init+0x83e/0x84a
>
>Remove the calls to bond_work_cancel_all() and destroy_workqueue();
>both are also called/scheduled via bond_free_all().
>
>bond_destroy_sysfs is unecessary because the sysfs entry has
>not been created in the error case.
>
>Signed-off-by: Florian Westphal <fw@strlen.de>

	Looks good to me.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J


> drivers/net/bonding/bond_main.c |    8 --------
> 1 files changed, 0 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 815191d..56830a4 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -5199,7 +5199,6 @@ static int __init bonding_init(void)
> {
> 	int i;
> 	int res;
>-	struct bonding *bond;
>
> 	printk(KERN_INFO "%s", version);
>
>@@ -5228,13 +5227,6 @@ static int __init bonding_init(void)
>
> 	goto out;
> err:
>-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
>-		bond_work_cancel_all(bond);
>-		destroy_workqueue(bond->wq);
>-	}
>-
>-	bond_destroy_sysfs();
>-
> 	rtnl_lock();
> 	bond_free_all();
> 	rtnl_unlock();
>-- 
>1.6.0.6
