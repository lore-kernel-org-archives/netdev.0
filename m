From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: Remove net_device_stats from bonding struct
Date: Tue, 02 Feb 2010 13:40:06 -0800
Message-ID: <16493.1265146806@death.nxdomain.ibm.com>
References: <20100202000648.GA30286@serverengines.com>
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59461 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753104Ab0BBVkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 16:40:11 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o12Lac1q032082
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2010 16:36:38 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o12LeAVt095394
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2010 16:40:10 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o12Le91r019094
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2010 19:40:10 -0200
In-reply-to: <20100202000648.GA30286@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajit Khaparde <ajitkhaparde@gmail.com> wrote:

>There is no need to maintain stats in the bonding structure.
>Use the instance of net_device_stats in netdevice.
>
>Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

	Note that the accumulation of stats across the slaves is done
into a separate local instance of net_device_stats, so partial results
shouldn't be visible.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

>---
> drivers/net/bonding/bond_main.c |    2 +-
> drivers/net/bonding/bonding.h   |    1 -
> 2 files changed, 1 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 6221936..1787e3c 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3742,7 +3742,7 @@ static int bond_close(struct net_device *bond_dev)
> static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
>-	struct net_device_stats *stats = &bond->stats;
>+	struct net_device_stats *stats = &bond_dev->stats;
> 	struct net_device_stats local_stats;
> 	struct slave *slave;
> 	int i;
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 558ec13..257a7a4 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -197,7 +197,6 @@ struct bonding {
> 	s8	 send_grat_arp;
> 	s8	 send_unsol_na;
> 	s8	 setup_by_slave;
>-	struct   net_device_stats stats;
> #ifdef CONFIG_PROC_FS
> 	struct   proc_dir_entry *proc_entry;
> 	char     proc_file_name[IFNAMSIZ];
>-- 
>1.6.3.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
