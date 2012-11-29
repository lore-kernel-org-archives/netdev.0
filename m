From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v3] bonding: make arp_ip_target parameter checks consistent with sysfs
Date: Thu, 29 Nov 2012 09:39:09 -0800
Message-ID: <13894.1354210749@death.nxdomain>
References: <1354121052-6263-1-git-send-email-nikolay@redhat.com> <1354188846-15577-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36271 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab2K2Rj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:39:28 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 29 Nov 2012 10:39:27 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 56B6D19D8036
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:39:24 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qATHdBu2139190
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:39:14 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qATHf6J6003563
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:41:07 -0700
In-reply-to: <1354188846-15577-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> The module can be loaded with arp_ip_target="255.255.255.255" which makes
> it impossible to remove as the function in sysfs checks for that value,
> so we make the parameter checks consistent with sysfs.
>
> v2: Fix formatting
> v3: Make description text < 75 columns
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_main.c | 5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 5f5b69f..d29159a 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4706,12 +4706,13 @@ static int bond_check_params(struct bond_params *params)
> 	     arp_ip_count++) {
> 		/* not complete check, but should be good enough to
> 		   catch mistakes */
>-		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
>+		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
>+		if (!isdigit(arp_ip_target[arp_ip_count][0]) ||
>+		    ip == 0 || ip == htonl(INADDR_BROADCAST)) {
> 			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
> 				   arp_ip_target[arp_ip_count]);
> 			arp_interval = 0;
> 		} else {
>-			__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
> 			arp_target[arp_ip_count] = ip;
> 		}
> 	}
>-- 
>1.7.11.7
>
