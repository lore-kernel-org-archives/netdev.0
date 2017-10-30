From: Doug Berger <opendmb@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: Avoid calling
 platform_device_put() twice in bcmgenet_mii_exit()
Date: Mon, 30 Oct 2017 11:58:50 -0700
Message-ID: <baff8a12-c8e3-8177-8df0-8b52016a7679@gmail.com>
References: <1509167146-93171-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wei Yongjun <weiyongjun1@huawei.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:50114 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932490AbdJ3S6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 14:58:55 -0400
Received: by mail-qk0-f196.google.com with SMTP id q83so17474639qke.6
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 11:58:55 -0700 (PDT)
In-Reply-To: <1509167146-93171-1-git-send-email-weiyongjun1@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2017 10:05 PM, Wei Yongjun wrote:
> Remove platform_device_put() call after platform_device_unregister()
> from function bcmgenet_mii_exit(), otherwise, we will call
> platform_device_put() twice.
> 
> Fixes: 9a4e79697009 ("net: bcmgenet: utilize generic Broadcom UniMAC
> MDIO controller driver")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmmii.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> index ba3fcfd..5333274 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> @@ -571,5 +571,4 @@ void bcmgenet_mii_exit(struct net_device *dev)
>  		of_phy_deregister_fixed_link(dn);
>  	of_node_put(priv->phy_dn);
>  	platform_device_unregister(priv->mii_pdev);
> -	platform_device_put(priv->mii_pdev);
>  }
> 
Acked-by: Doug Berger <opendmb@gmail.com>
