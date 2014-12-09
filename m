From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/4 net-next] net: bcmgenet: rework Tx queue init
Date: Tue, 09 Dec 2014 12:02:36 -0800
Message-ID: <5487555C.7080103@gmail.com>
References: <20141204041140.8D0612200C7@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:43300 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbaLIUCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:02:51 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so1211828pdj.14
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 12:02:51 -0800 (PST)
In-Reply-To: <20141204041140.8D0612200C7@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/14 20:11, Petri Gynther wrote:
> 1. Rename bcmgenet_init_multiq() to bcmgenet_init_tx_queues()
> 2. Move Tx default queue init inside bcmgenet_init_tx_queues()

One minor nit, see below, once resolved, feel free to add a:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 82 +++++++++++---------------
>  1 file changed, 36 insertions(+), 46 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 78ab733..eba310a 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1776,78 +1776,74 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
>  	return ret;
>  }
>  
> -/* init multi xmit queues, only available for GENET2+
> - * the queue is partitioned as follows:
> +/*
> + * Initialize Tx queues

This looks good to me, but same comment as David made, you are modifying
the comment style, and this is no longer conforming to what the network
drivers are using.
--
Florian
