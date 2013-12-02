From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] net/mlx4_core: destroy workqueue when driver fails to register
Date: Mon, 2 Dec 2013 22:11:52 +0200
Message-ID: <CAJZOPZLfiBR_ibMXpsec2U59hxoaqQoBVDOcGkr20mqtM5NYow@mail.gmail.com>
References: <1385948684-7284-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33359 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757184Ab3LBULx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 15:11:53 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so19003499pdi.10
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 12:11:52 -0800 (PST)
In-Reply-To: <1385948684-7284-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 2, 2013 at 3:44 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
> When driver registration fails, we need to clean up the resources allocated
> before. mlx4_core missed to destroy the workqueue allocated.

please use "missed destroying" instead of "missed to destroy"

>
> This patch destroies the workqueue when registration fails.

please s/destroies/destroys/

>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 5789ea2..01fc651 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2635,6 +2635,8 @@ static int __init mlx4_init(void)
>                 return -ENOMEM;
>
>         ret = pci_register_driver(&mlx4_driver);
> +       if (ret < 0)
> +               destroy_workqueue(mlx4_wq);
>         return ret < 0 ? ret : 0;
>  }
>
> --
> 1.7.5.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
