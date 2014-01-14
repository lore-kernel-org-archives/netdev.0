From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH 2/2] net/mlx4_core: clean up srq_res_start_move_to()
Date: Tue, 14 Jan 2014 08:40:50 +0200
Message-ID: <20140114084050.70a612af@jpm-OptiPlex-GX620>
References: <1389099734.15032.20.camel@x41>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:39789 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbaANGk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:40:58 -0500
Received: by mail-ea0-f182.google.com with SMTP id a15so3710450eae.41
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 22:40:57 -0800 (PST)
In-Reply-To: <1389099734.15032.20.camel@x41>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Jan 2014 14:02:14 +0100
Paul Bolle <pebolle@tiscali.nl> wrote:

> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c index
> a41f01e..8ace450 100644 ---
> a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c +++
> b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c @@ -1372,7
> +1372,7 @@ static int cq_res_start_move_to(struct mlx4_dev *dev, int
> slave, int cqn, } 
>  static int srq_res_start_move_to(struct mlx4_dev *dev, int slave,
> int index,
> -				 enum res_cq_states state, struct res_srq **srq)
> +				 enum res_srq_states state, struct res_srq **srq) {

ACK


> +		/* state == RES_SRQ_HW */
> +		if (r->com.state != RES_SRQ_ALLOCATED)

if (state != RES_SRQ_HW || r->com.state != RES_SRQ_ALLOCATED)

>  			err = -EINVAL;
> -		}
> +	}
>  
> -		if (!err) {
> -			r->com.from_state = r->com.state;
> -			r->com.to_state = state;
> -			r->com.state = RES_SRQ_BUSY;
> -			if (srq)
> -				*srq = r;
> -		}
> +	if (!err) {
> +		r->com.from_state = r->com.state;
> +		r->com.to_state = state;
> +		r->com.state = RES_SRQ_BUSY;
	please leave in the if (srq). Not currently needed, but if this
	changes in the future, we will get an Oops.
> +		*srq = r;
>  	}
>  
>  	spin_unlock_irq(mlx4_tlock(dev));
