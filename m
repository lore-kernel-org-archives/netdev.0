From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: dev: fix nlmsg size calculation in can_get_size()
Date: Sat, 05 Oct 2013 22:50:05 +0200
Message-ID: <52507B7D.6030008@grandegger.com>
References: <1381001117-19624-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, kernel@pengutronix.de
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1381001117-19624-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/05/2013 09:25 PM, Marc Kleine-Budde wrote:
> This patch fixes the calculation of the nlmsg size, by adding the missing
> nla_total_size().
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
> Hello,
> 
> this patch touches the rtnl_link_ops get_size() callback:
> 
>     static struct rtnl_link_ops can_link_ops __read_mostly = {
>     ...
>     	.get_size	= can_get_size,
>     ...
>     };
> 
> By looking at other nlmsg size calculation I think a nla_total_size() for all
> contributers is needed. Am I correct?

Yes, seems so, nla_put() calls this code:

  http://lxr.free-electrons.com/source/lib/nlattr.c#L328

Wolfgang.

> regards,
> Marc
> 
>  drivers/net/can/dev.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index f9cba41..1870c47 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -705,14 +705,14 @@ static size_t can_get_size(const struct net_device *dev)
>  	size_t size;
>  
>  	size = nla_total_size(sizeof(u32));   /* IFLA_CAN_STATE */
> -	size += sizeof(struct can_ctrlmode);  /* IFLA_CAN_CTRLMODE */
> +	size += nla_total_size(sizeof(struct can_ctrlmode));  /* IFLA_CAN_CTRLMODE */
>  	size += nla_total_size(sizeof(u32));  /* IFLA_CAN_RESTART_MS */
> -	size += sizeof(struct can_bittiming); /* IFLA_CAN_BITTIMING */
> -	size += sizeof(struct can_clock);     /* IFLA_CAN_CLOCK */
> +	size += nla_total_size(sizeof(struct can_bittiming)); /* IFLA_CAN_BITTIMING */
> +	size += nla_total_size(sizeof(struct can_clock));     /* IFLA_CAN_CLOCK */
>  	if (priv->do_get_berr_counter)        /* IFLA_CAN_BERR_COUNTER */
> -		size += sizeof(struct can_berr_counter);
> +		size += nla_total_size(sizeof(struct can_berr_counter));
>  	if (priv->bittiming_const)	      /* IFLA_CAN_BITTIMING_CONST */
> -		size += sizeof(struct can_bittiming_const);
> +		size += nla_total_size(sizeof(struct can_bittiming_const));
>  
>  	return size;
>  }
> 

