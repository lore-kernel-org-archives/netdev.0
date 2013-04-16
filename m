From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] atl1: Protect atl1_suspend with CONFIG_PM_SLEEP
Date: Wed, 17 Apr 2013 01:45:19 +0400
Message-ID: <516DC66F.2000309@cogentembedded.com>
References: <1366148100-5617-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, joe@perches.com,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:38003 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965371Ab3DPVqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:46:11 -0400
Received: by mail-la0-f51.google.com with SMTP id fo12so881909lab.24
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:46:10 -0700 (PDT)
In-Reply-To: <1366148100-5617-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/17/2013 01:35 AM, Fabio Estevam wrote:

> From: Fabio Estevam <fabio.estevam@freescale.com>
>
> commit 7b7a2bbb690 (atl1: Remove unneeded PM_OPS definitions) removed the
> definition of atl1_suspend for the !CONFIG_PM_SLEEP case.
>
> So only call atl1_suspend() when CONFIG_PM_SLEEP is defined and fix the
> following build error from randconfig:
>
> drivers/net/ethernet/atheros/atlx/atl1.c: In function 'atl1_shutdown':
> drivers/net/ethernet/atheros/atlx/atl1.c:2888:2: error: implicit declaration of function 'atl1_suspend' [-Werror=implicit-function-declaration]
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
>   drivers/net/ethernet/atheros/atlx/atl1.c |    2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
> index 9843c70..8338013 100644
> --- a/drivers/net/ethernet/atheros/atlx/atl1.c
> +++ b/drivers/net/ethernet/atheros/atlx/atl1.c
> @@ -2885,7 +2885,9 @@ static void atl1_shutdown(struct pci_dev *pdev)
>   	struct net_device *netdev = pci_get_drvdata(pdev);
>   	struct atl1_adapter *adapter = netdev_priv(netdev);
>   
> +#ifdef CONFIG_PM_SLEEP
>   	atl1_suspend(&pdev->dev);
> +#endif

    This is not the best practice as #ifdef's in the function bodies are 
not encouraged.
Better enclose

atl1_suspend() in #ifdef CONFIG_PM_SLEEP
  and define it as an empty static inline function in the #else clause.


WBR, Sergei
