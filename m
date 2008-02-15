From: "Rune Torgersen" <runet@innovsys.com>
Subject: RE: [PATCH] fs_enet: Don't call phy_mii_ioctl() in atomic context.
Date: Fri, 15 Feb 2008 15:47:32 -0600
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93B04006942@ismail.innsys.innovsys.com>
References: <20080215210804.GA14468@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: "Scott Wood" <scottwood@freescale.com>, <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.innovsys.com ([66.115.232.196]:36051 "EHLO
	mail.innovsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753065AbYBOVrf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 16:47:35 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080215210804.GA14468@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> The lock acquisition in fs_ioctl() does not appear to actually be
> necessary, and thus is simply removed.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com> ---
> This fixes the following bug:
> http://ozlabs.org/pipermail/linuxppc-dev/2008-February/051564.html
> 
>  drivers/net/fs_enet/fs_enet-main.c |    7 +------
>  1 files changed, 1 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/fs_enet-main.c
> b/drivers/net/fs_enet/fs_enet-main.c
> index 42d94ed..af869cf 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -946,16 +946,11 @@ static int fs_ioctl(struct net_device
> *dev, struct ifreq *rq, int cmd)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
>  	struct mii_ioctl_data *mii = (struct mii_ioctl_data
*)&rq->ifr_data;
> -	unsigned long flags;
> -	int rc;
> 
>  	if (!netif_running(dev))
>  		return -EINVAL;
> 
> -	spin_lock_irqsave(&fep->lock, flags);
> -	rc = phy_mii_ioctl(fep->phydev, mii, cmd);
> -	spin_unlock_irqrestore(&fep->lock, flags);
> -	return rc;
> +	return phy_mii_ioctl(fep->phydev, mii, cmd);
>  }
> 
>  extern int fs_mii_connect(struct net_device *dev);

Acked-by: Rune Torgersen <runet@innovsys.com>

Tested it and it does indeed take care of the bug.
