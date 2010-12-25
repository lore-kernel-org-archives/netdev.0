From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 9/9] can: pch_can: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 16:52:20 +0100
Message-ID: <4D161334.3090100@hartkopp.net>
References: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
	<1293288034-22428-10-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1293288034-22428-10-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 25.12.2010 15:40, Marc Kleine-Budde wrote:
> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Cc: Tomoya <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c |   15 ++++++++-------
>  1 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index c42e972..ee488ac 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -692,16 +692,17 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
>  			cf->can_id = id;
>  		}
>  
> -		if (id2 & PCH_ID2_DIR)
> -			cf->can_id |= CAN_RTR_FLAG;
> -
>  		cf->can_dlc = get_can_dlc((ioread32(&priv->regs->
>  						    ifregs[0].mcont)) & 0xF);
>  
> -		for (i = 0; i < cf->can_dlc; i += 2) {
> -			data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
> -			cf->data[i] = data_reg;
> -			cf->data[i + 1] = data_reg >> 8;
> +		if (id2 & PCH_ID2_DIR) {
> +			cf->can_id |= CAN_RTR_FLAG;
> +

} else {

???

> +			for (i = 0; i < cf->can_dlc; i += 2) {
> +				data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
> +				cf->data[i] = data_reg;
> +				cf->data[i + 1] = data_reg >> 8;
> +			}
>  		}
>  
>  		netif_receive_skb(skb);

Regards,
Oliver
