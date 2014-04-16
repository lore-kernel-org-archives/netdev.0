From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] mlx4_en: don't use napi_synchronize inside mlx4_en_netpoll
Date: Wed, 16 Apr 2014 17:20:44 +0300
Message-ID: <534E91BC.1030908@mellanox.com>
References: <534DAE14.2090604@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Chris Mason <clm@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:37746 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161177AbaDPOU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 10:20:59 -0400
In-Reply-To: <534DAE14.2090604@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/16/2014 1:09 AM, Chris Mason wrote:
>
>
> The mlx4 driver is triggering schedules while atomic inside
> mlx4_en_netpoll:
>
> 	spin_lock_irqsave(&cq->lock, flags);
> 	napi_synchronize(&cq->napi);
> 		^^^^^ msleep here
> 	mlx4_en_process_rx_cq(dev, cq, 0);
> 	spin_unlock_irqrestore(&cq->lock, flags);
>
> This was part of a patch by Alexander Guller from Mellanox in 2011,
> but it still isn't upstream.
>
> Signed-off-by: Chris Mason <clm@fb.com>
> cc: stable@vger.kernel.org
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_cq.c     | 1 -
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 6 +-----
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 1 -
>   3 files changed, 1 insertion(+), 7 deletions(-)
>

Acked-By: Amir Vadai <amirv@mellanox.com>
