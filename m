From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: fix return value of bonding_store_slaves_active()
Date: Tue, 25 Jan 2011 11:22:50 -0800
Message-ID: <29198.1295983370@death>
References: <20110125185315.GB2932@psychotron.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:60921 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab1AYTW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 14:22:56 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0PJ8ig9030983
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 12:08:44 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0PJMsXu152674
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 12:22:54 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0PJMrMY019256
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 12:22:53 -0700
In-reply-to: <20110125185315.GB2932@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>count is incorrectly returned even in case of fail. Return ret instead.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>

	It looks like bonding_store_carrier has the same problem, could
you fix it up too and resubmit?

	-J


>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 8fd0174..f33155f 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1595,7 +1595,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
> 		}
> 	}
> out:
>-	return count;
>+	return ret;
> }
> static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
> 		   bonding_show_slaves_active, bonding_store_slaves_active);

