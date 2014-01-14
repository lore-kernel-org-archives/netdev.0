From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH 1/2] net/mlx4_core: clean up cq_res_start_move_to()
Date: Tue, 14 Jan 2014 08:47:52 +0200
Message-ID: <20140114084752.1db64b21@jpm-OptiPlex-GX620>
References: <1389099678.15032.19.camel@x41>
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
Received: from mail-ee0-f41.google.com ([74.125.83.41]:33208 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbaANGry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:47:54 -0500
Received: by mail-ee0-f41.google.com with SMTP id e49so1883614eek.28
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 22:47:53 -0800 (PST)
In-Reply-To: <1389099678.15032.19.camel@x41>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This time, replying to the list as well.

-Jack
P.S. sorry for the delay, I was swamped.

On Tue, 07 Jan 2014 14:01:18 +0100
Paul Bolle <pebolle@tiscali.nl> wrote:

> +	} else {
> +		/* state == RES_CQ_HW */
> +		if (r->com.state != RES_CQ_ALLOCATED)

if (state != RES_CQ_HW || r->com.state != RES_CQ_ALLOCATED)
to protect against any bad calls to this function
(although I know that currently there are none).

This also preserves the behavior of the switch statement.

>  			err = -EINVAL;
> -		}
> +		else
> +			err = 0;
> +	}
>  
> -		if (!err) {
> -			r->com.from_state = r->com.state;
> -			r->com.to_state = state;
> -			r->com.state = RES_CQ_BUSY;
> -			if (cq)
> -				*cq = r;
> -		}
> +	if (!err) {
> +		r->com.from_state = r->com.state;
> +		r->com.to_state = state;
> +		r->com.state = RES_CQ_BUSY;

Please keep the "if" here.  Protects against (future) bad calls.

> +		*cq = r;
>  	}
