From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bonding: remove bond_resend_igmp_join_requests
 read_unlock leftover
Date: Sat, 27 Jul 2013 22:07:54 +0200
Message-ID: <20130727200754.GA2395@minipsycho.orion>
References: <1374945010-14667-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:46813 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab3G0UH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 16:07:58 -0400
Received: by mail-ea0-f177.google.com with SMTP id f10so1576222eak.36
        for <netdev@vger.kernel.org>; Sat, 27 Jul 2013 13:07:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1374945010-14667-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 27, 2013 at 07:10:10PM CEST, nikolay@redhat.com wrote:
>After commit 4aa5dee4d9 ("net: convert resend IGMP to notifier event") we
>have 1 read_unlock in bond_resend_igmp_join_requests which isn't paired
>with a read_lock because it's removed by that commit.

Oups

>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>


>---
> drivers/net/bonding/bond_main.c | 1 -
> 1 file changed, 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index f584352..da3af63 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -739,7 +739,6 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
> 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
> 	}
> 	write_unlock_bh(&bond->curr_slave_lock);
>-	read_unlock(&bond->lock);
> }
> 
> static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
>-- 
>1.8.1.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
