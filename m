From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2] bonding: fix race condition in bonding_store_slaves_active
Date: Thu, 29 Nov 2012 09:37:56 -0800
Message-ID: <13839.1354210676@death.nxdomain>
References: <1353759595-30452-1-git-send-email-nikolay@redhat.com> <1354189079-15754-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:35430 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab2K2RiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:38:22 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 29 Nov 2012 10:38:21 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A81231FF001B
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:38:00 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qATHc37T242634
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:38:04 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qATHc2wA023841
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:38:03 -0700
In-reply-to: <1354189079-15754-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> Race between bonding_store_slaves_active() and slave manipulation 
> functions. The bond_for_each_slave use in bonding_store_slaves_active()
> is not protected by any synchronization mechanism.
> NULL pointer dereference is easy to reach.
> Fixed by acquiring the bond->lock for the slave walk.
>
> v2: Make description text < 75 columns
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_sysfs.c | 2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index ef8d2a0..ba4f95b 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1582,6 +1582,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
> 		goto out;
> 	}
>
>+	read_lock(&bond->lock);
> 	bond_for_each_slave(bond, slave, i) {
> 		if (!bond_is_active_slave(slave)) {
> 			if (new_value)
>@@ -1590,6 +1591,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
> 				slave->inactive = 1;
> 		}
> 	}
>+	read_unlock(&bond->lock);
> out:
> 	return ret;
> }
>-- 
>1.7.11.7
>
