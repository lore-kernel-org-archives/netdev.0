From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: set primary param via sysfs
Date: Fri, 18 Sep 2009 16:02:31 -0700
Message-ID: <10714.1253314951@death.nxdomain.ibm.com>
References: <20090918121321.GB2801@psychotron.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:36636 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658AbZIRXCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 19:02:37 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8IMqb23015207
	for <netdev@vger.kernel.org>; Fri, 18 Sep 2009 16:52:37 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8IN2aQ3233942
	for <netdev@vger.kernel.org>; Fri, 18 Sep 2009 17:02:36 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8IN2ZLE004784
	for <netdev@vger.kernel.org>; Fri, 18 Sep 2009 17:02:36 -0600
In-reply-to: <20090918121321.GB2801@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>Primary module parameter passed to bonding is pernament. That means if you
>release the primary slave and enslave it again, it becomes the primary slave
>again. But if you set primary slave via sysfs, the primary slave is only set
>once and it's not remembered in bond->params structure. Therefore the setting is
>lost after releasing the primary slave. This simple one-liner fixes this.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 6044e12..ff449de 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1182,6 +1182,7 @@ static ssize_t bonding_store_primary(struct device *d,
> 				       ": %s: Setting %s as primary slave.\n",
> 				       bond->dev->name, slave->dev->name);
> 				bond->primary_slave = slave;
>+				strcpy(bond->params.primary, slave->dev->name);
> 				bond_select_active_slave(bond);
> 				goto out;
> 			}

	Looks good, fixes another bug I'd not heard of previously.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
