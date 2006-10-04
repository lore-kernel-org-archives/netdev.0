From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [PATCH] b44: fix multicast with >32 groups
Date: Wed, 04 Oct 2006 12:32:14 -0700
Message-ID: <1159990334.14865.5.camel@dhcp-10-7-81-7.broadcom.com>
References: <451D95D5.5010005@flitterfly.whirpon.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:64006 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750905AbWJDTew
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 15:34:52 -0400
To: "Bill Helfinstine" <bhelf@flitterfly.whirpon.com>
In-Reply-To: <451D95D5.5010005@flitterfly.whirpon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-29 at 17:53 -0400, Bill Helfinstine wrote:
> The b44 driver has a bug where if there are more than B44_MCAST_TABLE_SIZE 
> groups in the dev->mc_list, it will only listen to the first 
> B44_MCAST_TABLE_SIZE that it sees.
> 
> This patch makes the driver go into RXCONFIG_ALLMULTI mode if there are more 
> than B44_MCAST_TABLE_SIZE groups being subscribed to.
> 
> This patch is against 2.6.18, b44.c version 1.01.
> 
> 
> Signed-off-by: Bill Helfinstine <bhelf@flitterfly.whirpon.com>
> 
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index e891ea2..dd024e1 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -1706,7 +1706,8 @@ static void __b44_set_rx_mode(struct net
> 
>                  __b44_set_mac_addr(bp);
> 
> -               if (dev->flags & IFF_ALLMULTI)
> +               if ((dev->flags & IFF_ALLMULTI) ||
> +                   (dev->mc_count > B44_MCAST_TABLE_SIZE))
>                          val |= RXCONFIG_ALLMULTI;
>                  else
>                          i = __b44_load_mcast(bp, dev);
> 

It looks good to me, however, I'll have to nack it as this patch has spaces and will not apply.
Please convert the spaces to tabs.

Thanks,
Gary

