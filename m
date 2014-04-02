From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 3/5] bonding: Initialize the ALB work queue for lb
 mode only.
Date: Wed, 02 Apr 2014 04:03:30 -0700
Message-ID: <1396436610.3989.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396422012-32022-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46118 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758057AbaDBLDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 07:03:33 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so18375pbb.19
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 04:03:32 -0700 (PDT)
In-Reply-To: <1396422012-32022-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 00:00 -0700, Mahesh Bandewar wrote:
> micro change to initialize / cancel the ALB work queue only
> if the mode selected is ALB or TLB.
> 
> Change-Id: I27a6cf65f72819889bf15b68f6ef4fca7d617186
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v2:
>   Rebase
> v3:
>   Rebase
> 
>  drivers/net/bonding/bond_main.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 6e96d510bc8d..676db41b98bc 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3046,7 +3046,8 @@ static void bond_work_init_all(struct bonding *bond)
>  {
>  	INIT_DELAYED_WORK(&bond->mcast_work,
>  			  bond_resend_igmp_join_requests_delayed);
> -	INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
> +	if (bond_is_lb(bond))
> +		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
>  	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
>  	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
>  		INIT_DELAYED_WORK(&bond->arp_work, bond_activebackup_arp_mon);
> @@ -3059,7 +3060,8 @@ static void bond_work_cancel_all(struct bonding *bond)
>  {
>  	cancel_delayed_work_sync(&bond->mii_work);
>  	cancel_delayed_work_sync(&bond->arp_work);
> -	cancel_delayed_work_sync(&bond->alb_work);
> +	if (bond_is_lb(bond))
> +		cancel_delayed_work_sync(&bond->alb_work);
>  	cancel_delayed_work_sync(&bond->ad_work);
>  	cancel_delayed_work_sync(&bond->mcast_work);
>  }

I would prefer you drop this patch.

As I said, there is no gain but potential troubles with this,
bonding driver is heavily changed by lot of people. 

Its not like we setup/dismantle thousand of bonding devices per second
on a host.
