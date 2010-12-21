From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [patch -next] pch_can: off by one bugs
Date: Tue, 21 Dec 2010 21:41:52 +0100
Message-ID: <4D111110.2030609@grandegger.com>
References: <20101220092601.GS1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20101220092601.GS1936@bicker>
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

Hello,

On 12/20/2010 10:26 AM, Dan Carpenter wrote:
> priv->tx_enable[] has PCH_TX_OBJ_END elements so this code is
> reading and writing one past the end of the array.
> 
> Signed-off-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 8d45fdd..b2c1292 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -1077,7 +1077,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
>  	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
>  
>  	/* Save Tx buffer enable state */
> -	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
> +	for (i = PCH_TX_OBJ_START; i < PCH_TX_OBJ_END; i++)
>  		priv->tx_enable[i] = pch_can_get_rxtx_ir(priv, i, PCH_TX_IFREG);
>  
>  	/* Disable all Transmit buffers */
> @@ -1138,7 +1138,7 @@ static int pch_can_resume(struct pci_dev *pdev)
>  	pch_can_set_optmode(priv);
>  
>  	/* Enabling the transmit buffer. */
> -	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
> +	for (i = PCH_TX_OBJ_START; i < PCH_TX_OBJ_END; i++)
>  		pch_can_set_rxtx(priv, i, priv->tx_enable[i], PCH_TX_IFREG);
>  
>  	/* Configuring the receive buffer and enabling them. */
> 

This fix does not look correct too me. There are much more loop using
"i <= PCH_TX_OBJ_END" and the message numbering is from 1..32. Therefore
using "priv->tx_enable[i - 1]" seems more appropriate to me. Tomaya,
could you please check.

Thanks,

Wolfgang.
