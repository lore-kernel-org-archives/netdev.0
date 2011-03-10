From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can : TI_HECC : Unintialized variables
Date: Thu, 10 Mar 2011 18:07:32 +0100
Message-ID: <4D790554.20204@grandegger.com>
References: <1299774087-8532-1-git-send-email-abhilash.kv@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Vaibhav Hiremath <hvaibhav-l0cyMroinI0@public.gmane.org>
To: Abhilash K V <abhilash.kv-l0cyMroinI0@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1299774087-8532-1-git-send-email-abhilash.kv-l0cyMroinI0@public.gmane.org>
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

On 03/10/2011 05:21 PM, Abhilash K V wrote:
> 1. In ti_hecc_xmit(), "data" is not initialized, causing
>    undesirable effects like setting the RTR field for every
>    transmit.

Does it need to be initialized to "data = cf->can_dlc"? If yes, please
correct the message, if not ...

> 2. In ti_hecc_probe(), the spinlock  priv->mbx_lock is not
>    inited, causing a spinlock lockup BUG.
> 
> Signed-off-by: Vaibhav Hiremath <hvaibhav-l0cyMroinI0@public.gmane.org>
> Acked-by: Anant Gole <anantgole-l0cyMroinI0@public.gmane.org>
> Signed-off-by: Abhilash K V <abhilash.kv-l0cyMroinI0@public.gmane.org>
> ---
>  drivers/net/can/ti_hecc.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index 4d07f1e..73c6025 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -503,6 +503,7 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	spin_unlock_irqrestore(&priv->mbx_lock, flags);
>  
>  	/* Prepare mailbox for transmission */
> +	data = cf->can_dlc;
>  	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
>  		data |= HECC_CANMCF_RTR;
>  	data |= get_tx_head_prio(priv) << 8;

... using the following expressions looks more reasonable:

  	data = get_tx_head_prio(priv) << 8;
 	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
 		data |= HECC_CANMCF_RTR;
	
Wolfgang.
