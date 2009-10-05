From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] net-next:can: add TI CAN (HECC) driver
Date: Mon, 05 Oct 2009 13:25:16 +0200
Message-ID: <4AC9D79C.1030406@grandegger.com>
References: <1254736974-6685-1-git-send-email-anantgole@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-xIg/pKzrS19vn6HldHNs0ANdhmdF6hFW@public.gmane.org
To: Anant Gole <anantgole-l0cyMroinI0@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1254736974-6685-1-git-send-email-anantgole-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Anant Gole wrote:
> TI HECC (High End CAN Controller) module is found on many TI devices. It
> has 32 hardware mailboxes with full implementation of CAN protocol 2.0B
> with bus speeds up to 1Mbps. Specifications of the module are available
> on TI web <http://www.ti.com>
> 
> Signed-off-by: Anant Gole <anantgole-l0cyMroinI0@public.gmane.org>

I already reviewed this driver on the Socketcan-core ML and it's almost
OK from the Socket-CAN point of view. Just one issue...

[snip]
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> new file mode 100644
> index 0000000..9090103
> --- /dev/null
> +++ b/drivers/net/can/ti_hecc.c
[snip]
> +static int ti_hecc_set_btc(struct ti_hecc_priv *priv)
> +{
> +	struct can_bittiming *bit_timing = &priv->can.bittiming;
> +	u32 can_btc;
> +
> +	can_btc = (bit_timing->phase_seg2 - 1) & 0x7;
> +	can_btc |= ((bit_timing->phase_seg1 + bit_timing->prop_seg - 1)
> +			& 0xF) << 3;
> +	if (bit_timing->brp > 4 && priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
> +			can_btc |= HECC_CANBTC_SAM;
> +	else
> +		dev_info(priv->ndev->dev.parent,
> +			"WARN: Triple sampling not set due to h/w limitations"
> +			" at %d bitrate", bit_timing->bitrate);

That's not correct from my point of view. The warning message should
only be printed when the user tries to set triple sampling. I think it
should be similar to:

	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) {
		if (bit_timing->brp > 4)
			can_btc |= HECC_CANBTC_SAM;
		else
			dev_warn(priv->ndev->dev.parent,
			"Triple sampling not set due to h/w "
			limitations");
	}

Apart from that, the patch looks OK.

Wolfgang.
