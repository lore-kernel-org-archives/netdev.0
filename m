From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC] Validate ethtool autoneg before relaying
Date: Wed, 26 Nov 2008 15:28:12 -0800
Message-ID: <1227742092.13189.19.camel@HP1>
References: <20081126221741.GA8800@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1277 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbYKZXbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 18:31:15 -0500
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 726182B0 for
 <netdev@vger.kernel.org>; Wed, 26 Nov 2008 15:31:01 -0800 (PST)
In-Reply-To: <20081126221741.GA8800@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-11-26 at 14:17 -0800, Matt Carlson wrote:
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 14ada53..6362f56 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -164,6 +164,9 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
>         if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
>                 return -EFAULT;
>  
> +       if (cmd.autoneg != AUTONEG_ENABLE && cmd.autoneg != AUTONEG_DISABLE)
> +               return -EFAULT;
> +

Matt, you should return -EINVAL here instead.

>         return dev->ethtool_ops->set_settings(dev, &cmd);
>  }
>  


