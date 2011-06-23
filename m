From: Joe Perches <joe@perches.com>
Subject: Re: [net-2.6 PATCH 2/3] qlge:Fix printk priority so chip fatal
 errors are always reported.
Date: Thu, 23 Jun 2011 11:50:49 -0700
Message-ID: <1308855049.6688.19.camel@Joe-Laptop>
References: <1308851544-25719-1-git-send-email-ron.mercer@qlogic.com>
	 <1308851544-25719-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jitendra.kalsaria@qlogic.com, ameen.rahman@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3183 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932625Ab1FWSuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 14:50:51 -0400
In-Reply-To: <1308851544-25719-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-23 at 10:52 -0700, Ron Mercer wrote:
> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> Precedence of the printk should be at higher level so chip
> 	fatal errors are always reported.

You probably want to use netdev_err then, not a masked
netif_err when it is optionally not reported.

> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
[]
> @@ -2170,7 +2170,7 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
>  		return;
>  
>  	case CAM_LOOKUP_ERR_EVENT:
> -		netif_err(qdev, link, qdev->ndev,
> +		netif_err(qdev, drv, qdev->ndev,
>  			  "Multiple CAM hits lookup occurred.\n");

		netdev_err(qdev->ndev, "Multiple CAM hits lookup occurred\n");

> @@ -2178,13 +2178,13 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
>  		return;
>  
>  	case SOFT_ECC_ERROR_EVENT:
> -		netif_err(qdev, rx_err, qdev->ndev,
> +		netif_err(qdev, drv, qdev->ndev,
>  			  "Soft ECC error detected.\n");

		netdev_err(qdev->ndev, "Soft ECC error detected\n");

etc...


