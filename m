From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net V1 1/2] net/bonding: emit address change event also in bond_release
Date: Wed, 04 Apr 2012 09:57:26 -0700
Message-ID: <17466.1333558646@death.nxdomain>
References: <1333529780-28421-1-git-send-email-ogerlitz@mellanox.com> <1333529780-28421-2-git-send-email-ogerlitz@mellanox.com>
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:59178 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932355Ab2DDQ5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 12:57:50 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 4 Apr 2012 10:57:49 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 0DC84C90052
	for <netdev@vger.kernel.org>; Wed,  4 Apr 2012 12:57:30 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q34GvUPc213196
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2012 12:57:30 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q34GvRV3000466
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2012 12:57:30 -0400
In-reply-to: <1333529780-28421-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@mellanox.com> wrote:

>From: Shlomo Pongratz <shlomop@mellanox.com>
>
>commit 7d26bb103c4 "bonding: emit event when bonding changes MAC" didn't
>take care to emit the NETDEV_CHANGEADDR event in bond_release, where bonding
>actually changes the mac address (to all zeroes). As a result the neighbours
>aren't deleted by the core networking code (which does so upon getting that
>event).
>
>Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_main.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index a20b585..d38f635 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2035,6 +2035,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 	write_unlock_bh(&bond->lock);
> 	unblock_netpoll_tx();
>
>+	if (bond->slave_cnt == 0)
>+		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>+
> 	bond_compute_features(bond);
> 	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
> 	    (old_features & NETIF_F_VLAN_CHALLENGED))
>-- 
>1.7.1
>
