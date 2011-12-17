From: Sebastian Haas <dev@sebastianhaas.info>
Subject: Re: [PATCH net-next] can: replace the dev_dbg/info/err/... with the
 new netdev_xxx macros
Date: Sat, 17 Dec 2011 16:12:00 +0100
Message-ID: <4EECB140.3030007@sebastianhaas.info>
References: <4EE61D71.90401@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Barry Song <barry.song@analog.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Anant Gole <anantgole@ti.com>,
	Chris Elston <celston@katalix.com>,
	Sebastian Haas <haas@ems-wuensche.com>,
	Matthias Fuchs <matthias.fuchs@esd.eu>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE61D71.90401@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks good for ems_usb. Thanks Wolfgang.

Acked-by: Sebastian Haas <dev@sebastianhaas.info>

Am 12.12.2011 16:27, schrieb Wolfgang Grandegger:
> CC: Barry Song<barry.song@analog.com>
> CC: Anant Gole<anantgole@ti.com>
> CC: Chris Elston<celston@katalix.com>
> CC: Sebastian Haas<haas@ems-wuensche.com>
> CC: Matthias Fuchs<matthias.fuchs@esd.eu>
> Signed-off-by: Wolfgang Grandegger<wg@grandegger.com>
> ---
>   drivers/net/can/bfin_can.c        |   21 +++++--------
>   drivers/net/can/dev.c             |   23 +++++++--------
>   drivers/net/can/flexcan.c         |   44 +++++++++++++---------------
>   drivers/net/can/mcp251x.c         |    3 +-
>   drivers/net/can/mscan/mscan.c     |   17 +++++------
>   drivers/net/can/sja1000/sja1000.c |   19 ++++++------
>   drivers/net/can/ti_hecc.c         |   20 ++++++------
>   drivers/net/can/usb/ems_usb.c     |   57 +++++++++++++++----------------------
>   drivers/net/can/usb/esd_usb2.c    |   27 ++++++++----------
>   9 files changed, 103 insertions(+), 128 deletions(-)
>
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> index 349e0fa..9cf4ddb 100644
> --- a/drivers/net/can/bfin_can.c
> +++ b/drivers/net/can/bfin_can.c
> @@ -82,8 +82,7 @@ static int bfin_can_set_bittiming(struct net_device *dev)
>   	bfin_write(&reg->clock, clk);
>   	bfin_write(&reg->timing, timing);
>
> -	dev_info(dev->dev.parent, "setting CLOCK=0x%04x TIMING=0x%04x\n",
> -			clk, timing);
> +	netdev_info(dev, "setting CLOCK=0x%04x TIMING=0x%04x\n", clk, timing);
>
>   	return 0;
>   }
> @@ -108,8 +107,7 @@ static void bfin_can_set_reset_mode(struct net_device *dev)
>   	while (!(bfin_read(&reg->control)&  CCA)) {
>   		udelay(10);
>   		if (--timeout == 0) {
> -			dev_err(dev->dev.parent,
> -					"fail to enter configuration mode\n");
> +			netdev_err(dev, "fail to enter configuration mode\n");
>   			BUG();
>   		}
>   	}
> @@ -165,8 +163,7 @@ static void bfin_can_set_normal_mode(struct net_device *dev)
>   	while (bfin_read(&reg->status)&  CCA) {
>   		udelay(10);
>   		if (--timeout == 0) {
> -			dev_err(dev->dev.parent,
> -					"fail to leave configuration mode\n");
> +			netdev_err(dev, "fail to leave configuration mode\n");
>   			BUG();
>   		}
>   	}
> @@ -331,7 +328,7 @@ static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
>
>   	if (isrc&  RMLIS) {
>   		/* data overrun interrupt */
> -		dev_dbg(dev->dev.parent, "data overrun interrupt\n");
> +		netdev_dbg(dev, "data overrun interrupt\n");
>   		cf->can_id |= CAN_ERR_CRTL;
>   		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
>   		stats->rx_over_errors++;
> @@ -339,7 +336,7 @@ static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
>   	}
>
>   	if (isrc&  BOIS) {
> -		dev_dbg(dev->dev.parent, "bus-off mode interrupt\n");
> +		netdev_dbg(dev, "bus-off mode interrupt\n");
>   		state = CAN_STATE_BUS_OFF;
>   		cf->can_id |= CAN_ERR_BUSOFF;
>   		can_bus_off(dev);
> @@ -347,13 +344,12 @@ static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
>
>   	if (isrc&  EPIS) {
>   		/* error passive interrupt */
> -		dev_dbg(dev->dev.parent, "error passive interrupt\n");
> +		netdev_dbg(dev, "error passive interrupt\n");
>   		state = CAN_STATE_ERROR_PASSIVE;
>   	}
>
>   	if ((isrc&  EWTIS) || (isrc&  EWRIS)) {
> -		dev_dbg(dev->dev.parent,
> -				"Error Warning Transmit/Receive Interrupt\n");
> +		netdev_dbg(dev, "Error Warning Transmit/Receive Interrupt\n");
>   		state = CAN_STATE_ERROR_WARNING;
>   	}
>
> @@ -636,8 +632,7 @@ static int bfin_can_suspend(struct platform_device *pdev, pm_message_t mesg)
>   		while (!(bfin_read(&reg->intr)&  SMACK)) {
>   			udelay(10);
>   			if (--timeout == 0) {
> -				dev_err(dev->dev.parent,
> -						"fail to enter sleep mode\n");
> +				netdev_err(dev, "fail to enter sleep mode\n");
>   				BUG();
>   			}
>   		}
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index 120f1ab..ac4ac92 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -130,13 +130,13 @@ static int can_calc_bittiming(struct net_device *dev, struct can_bittiming *bt)
>   		/* Error in one-tenth of a percent */
>   		error = (best_error * 1000) / bt->bitrate;
>   		if (error>  CAN_CALC_MAX_ERROR) {
> -			dev_err(dev->dev.parent,
> -				"bitrate error %ld.%ld%% too high\n",
> -				error / 10, error % 10);
> +			netdev_err(dev,
> +				   "bitrate error %ld.%ld%% too high\n",
> +				   error / 10, error % 10);
>   			return -EDOM;
>   		} else {
> -			dev_warn(dev->dev.parent, "bitrate error %ld.%ld%%\n",
> -				 error / 10, error % 10);
> +			netdev_warn(dev, "bitrate error %ld.%ld%%\n",
> +				    error / 10, error % 10);
>   		}
>   	}
>
> @@ -172,7 +172,7 @@ static int can_calc_bittiming(struct net_device *dev, struct can_bittiming *bt)
>   #else /* !CONFIG_CAN_CALC_BITTIMING */
>   static int can_calc_bittiming(struct net_device *dev, struct can_bittiming *bt)
>   {
> -	dev_err(dev->dev.parent, "bit-timing calculation not available\n");
> +	netdev_err(dev, "bit-timing calculation not available\n");
>   	return -EINVAL;
>   }
>   #endif /* CONFIG_CAN_CALC_BITTIMING */
> @@ -313,8 +313,7 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
>   		priv->echo_skb[idx] = skb;
>   	} else {
>   		/* locking problem with netif_stop_queue() ?? */
> -		dev_err(dev->dev.parent, "%s: BUG! echo_skb is occupied!\n",
> -			__func__);
> +		netdev_err(dev, "%s: BUG! echo_skb is occupied!\n", __func__);
>   		kfree_skb(skb);
>   	}
>   }
> @@ -392,7 +391,7 @@ void can_restart(unsigned long data)
>   	stats->rx_bytes += cf->can_dlc;
>
>   restart:
> -	dev_dbg(dev->dev.parent, "restarted\n");
> +	netdev_dbg(dev, "restarted\n");
>   	priv->can_stats.restarts++;
>
>   	/* Now restart the device */
> @@ -400,7 +399,7 @@ restart:
>
>   	netif_carrier_on(dev);
>   	if (err)
> -		dev_err(dev->dev.parent, "Error %d during restart", err);
> +		netdev_err(dev, "Error %d during restart", err);
>   }
>
>   int can_restart_now(struct net_device *dev)
> @@ -433,7 +432,7 @@ void can_bus_off(struct net_device *dev)
>   {
>   	struct can_priv *priv = netdev_priv(dev);
>
> -	dev_dbg(dev->dev.parent, "bus-off\n");
> +	netdev_dbg(dev, "bus-off\n");
>
>   	netif_carrier_off(dev);
>   	priv->can_stats.bus_off++;
> @@ -545,7 +544,7 @@ int open_candev(struct net_device *dev)
>   	struct can_priv *priv = netdev_priv(dev);
>
>   	if (!priv->bittiming.tq&&  !priv->bittiming.bitrate) {
> -		dev_err(dev->dev.parent, "bit-timing not yet defined\n");
> +		netdev_err(dev, "bit-timing not yet defined\n");
>   		return -EINVAL;
>   	}
>
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index 111f154..e40afad 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -322,34 +322,34 @@ static void do_bus_err(struct net_device *dev,
>   	cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>
>   	if (reg_esr&  FLEXCAN_ESR_BIT1_ERR) {
> -		dev_dbg(dev->dev.parent, "BIT1_ERR irq\n");
> +		netdev_dbg(dev, "BIT1_ERR irq\n");
>   		cf->data[2] |= CAN_ERR_PROT_BIT1;
>   		tx_errors = 1;
>   	}
>   	if (reg_esr&  FLEXCAN_ESR_BIT0_ERR) {
> -		dev_dbg(dev->dev.parent, "BIT0_ERR irq\n");
> +		netdev_dbg(dev, "BIT0_ERR irq\n");
>   		cf->data[2] |= CAN_ERR_PROT_BIT0;
>   		tx_errors = 1;
>   	}
>   	if (reg_esr&  FLEXCAN_ESR_ACK_ERR) {
> -		dev_dbg(dev->dev.parent, "ACK_ERR irq\n");
> +		netdev_dbg(dev, "ACK_ERR irq\n");
>   		cf->can_id |= CAN_ERR_ACK;
>   		cf->data[3] |= CAN_ERR_PROT_LOC_ACK;
>   		tx_errors = 1;
>   	}
>   	if (reg_esr&  FLEXCAN_ESR_CRC_ERR) {
> -		dev_dbg(dev->dev.parent, "CRC_ERR irq\n");
> +		netdev_dbg(dev, "CRC_ERR irq\n");
>   		cf->data[2] |= CAN_ERR_PROT_BIT;
>   		cf->data[3] |= CAN_ERR_PROT_LOC_CRC_SEQ;
>   		rx_errors = 1;
>   	}
>   	if (reg_esr&  FLEXCAN_ESR_FRM_ERR) {
> -		dev_dbg(dev->dev.parent, "FRM_ERR irq\n");
> +		netdev_dbg(dev, "FRM_ERR irq\n");
>   		cf->data[2] |= CAN_ERR_PROT_FORM;
>   		rx_errors = 1;
>   	}
>   	if (reg_esr&  FLEXCAN_ESR_STF_ERR) {
> -		dev_dbg(dev->dev.parent, "STF_ERR irq\n");
> +		netdev_dbg(dev, "STF_ERR irq\n");
>   		cf->data[2] |= CAN_ERR_PROT_STUFF;
>   		rx_errors = 1;
>   	}
> @@ -396,7 +396,7 @@ static void do_state(struct net_device *dev,
>   		 */
>   		if (new_state>= CAN_STATE_ERROR_WARNING&&
>   		new_state<= CAN_STATE_BUS_OFF) {
> -			dev_dbg(dev->dev.parent, "Error Warning IRQ\n");
> +			netdev_dbg(dev, "Error Warning IRQ\n");
>   			priv->can.can_stats.error_warning++;
>
>   			cf->can_id |= CAN_ERR_CRTL;
> @@ -412,7 +412,7 @@ static void do_state(struct net_device *dev,
>   		 */
>   		if (new_state>= CAN_STATE_ERROR_PASSIVE&&
>   		new_state<= CAN_STATE_BUS_OFF) {
> -			dev_dbg(dev->dev.parent, "Error Passive IRQ\n");
> +			netdev_dbg(dev, "Error Passive IRQ\n");
>   			priv->can.can_stats.error_passive++;
>
>   			cf->can_id |= CAN_ERR_CRTL;
> @@ -422,8 +422,8 @@ static void do_state(struct net_device *dev,
>   		}
>   		break;
>   	case CAN_STATE_BUS_OFF:
> -		dev_err(dev->dev.parent,
> -			"BUG! hardware recovered automatically from BUS_OFF\n");
> +		netdev_err(dev, "BUG! "
> +			   "hardware recovered automatically from BUS_OFF\n");
>   		break;
>   	default:
>   		break;
> @@ -432,7 +432,7 @@ static void do_state(struct net_device *dev,
>   	/* process state changes depending on the new state */
>   	switch (new_state) {
>   	case CAN_STATE_ERROR_ACTIVE:
> -		dev_dbg(dev->dev.parent, "Error Active\n");
> +		netdev_dbg(dev, "Error Active\n");
>   		cf->can_id |= CAN_ERR_PROT;
>   		cf->data[2] = CAN_ERR_PROT_ACTIVE;
>   		break;
> @@ -653,12 +653,12 @@ static void flexcan_set_bittiming(struct net_device *dev)
>   	if (priv->can.ctrlmode&  CAN_CTRLMODE_3_SAMPLES)
>   		reg |= FLEXCAN_CTRL_SMP;
>
> -	dev_info(dev->dev.parent, "writing ctrl=0x%08x\n", reg);
> +	netdev_info(dev, "writing ctrl=0x%08x\n", reg);
>   	flexcan_write(reg,&regs->ctrl);
>
>   	/* print chip status */
> -	dev_dbg(dev->dev.parent, "%s: mcr=0x%08x ctrl=0x%08x\n", __func__,
> -		flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
> +	netdev_dbg(dev, "%s: mcr=0x%08x ctrl=0x%08x\n", __func__,
> +		   flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
>   }
>
>   /*
> @@ -684,9 +684,8 @@ static int flexcan_chip_start(struct net_device *dev)
>
>   	reg_mcr = flexcan_read(&regs->mcr);
>   	if (reg_mcr&  FLEXCAN_MCR_SOFTRST) {
> -		dev_err(dev->dev.parent,
> -			"Failed to softreset can module (mcr=0x%08x)\n",
> -			reg_mcr);
> +		netdev_err(dev, "Failed to softreset can module (mcr=0x%08x)\n",
> +			   reg_mcr);
>   		err = -ENODEV;
>   		goto out;
>   	}
> @@ -708,7 +707,7 @@ static int flexcan_chip_start(struct net_device *dev)
>   	reg_mcr |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
>   		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
>   		FLEXCAN_MCR_IDAM_C;
> -	dev_dbg(dev->dev.parent, "%s: writing mcr=0x%08x", __func__, reg_mcr);
> +	netdev_dbg(dev, "%s: writing mcr=0x%08x", __func__, reg_mcr);
>   	flexcan_write(reg_mcr,&regs->mcr);
>
>   	/*
> @@ -734,7 +733,7 @@ static int flexcan_chip_start(struct net_device *dev)
>
>   	/* save for later use */
>   	priv->reg_ctrl_default = reg_ctrl;
> -	dev_dbg(dev->dev.parent, "%s: writing ctrl=0x%08x", __func__, reg_ctrl);
> +	netdev_dbg(dev, "%s: writing ctrl=0x%08x", __func__, reg_ctrl);
>   	flexcan_write(reg_ctrl,&regs->ctrl);
>
>   	for (i = 0; i<  ARRAY_SIZE(regs->cantxfg); i++) {
> @@ -766,8 +765,8 @@ static int flexcan_chip_start(struct net_device *dev)
>   	flexcan_write(FLEXCAN_IFLAG_DEFAULT,&regs->imask1);
>
>   	/* print chip status */
> -	dev_dbg(dev->dev.parent, "%s: reading mcr=0x%08x ctrl=0x%08x\n",
> -		__func__, flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
> +	netdev_dbg(dev, "%s: reading mcr=0x%08x ctrl=0x%08x\n", __func__,
> +		   flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
>
>   	return 0;
>
> @@ -905,8 +904,7 @@ static int __devinit register_flexcandev(struct net_device *dev)
>   	 */
>   	reg = flexcan_read(&regs->mcr);
>   	if (!(reg&  FLEXCAN_MCR_FEN)) {
> -		dev_err(dev->dev.parent,
> -			"Could not enable RX FIFO, unsupported core\n");
> +		netdev_err(dev, "Could not enable RX FIFO, unsupported core\n");
>   		err = -ENODEV;
>   		goto out;
>   	}
> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> index 330140e..346785c 100644
> --- a/drivers/net/can/mcp251x.c
> +++ b/drivers/net/can/mcp251x.c
> @@ -712,8 +712,7 @@ static void mcp251x_error_skb(struct net_device *net, int can_id, int data1)
>   		frame->data[1] = data1;
>   		netif_rx_ni(skb);
>   	} else {
> -		dev_err(&net->dev,
> -			"cannot allocate error skb\n");
> +		netdev_err(net, "cannot allocate error skb\n");
>   	}
>   }
>
> diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
> index 1c82dd8..ad8e687 100644
> --- a/drivers/net/can/mscan/mscan.c
> +++ b/drivers/net/can/mscan/mscan.c
> @@ -95,9 +95,9 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
>   			 * any, at once.
>   			 */
>   			if (i>= MSCAN_SET_MODE_RETRIES)
> -				dev_dbg(dev->dev.parent,
> -					"device failed to enter sleep mode. "
> -					"We proceed anyhow.\n");
> +				netdev_dbg(dev,
> +					   "device failed to enter sleep mode. "
> +					   "We proceed anyhow.\n");
>   			else
>   				priv->can.state = CAN_STATE_SLEEPING;
>   		}
> @@ -213,7 +213,7 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	switch (hweight8(i)) {
>   	case 0:
>   		netif_stop_queue(dev);
> -		dev_err(dev->dev.parent, "Tx Ring full when queue awake!\n");
> +		netdev_err(dev, "Tx Ring full when queue awake!\n");
>   		return NETDEV_TX_BUSY;
>   	case 1:
>   		/*
> @@ -352,7 +352,7 @@ static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
>   	struct net_device_stats *stats =&dev->stats;
>   	enum can_state old_state;
>
> -	dev_dbg(dev->dev.parent, "error interrupt (canrflg=%#x)\n", canrflg);
> +	netdev_dbg(dev, "error interrupt (canrflg=%#x)\n", canrflg);
>   	frame->can_id = CAN_ERR_FLAG;
>
>   	if (canrflg&  MSCAN_OVRIF) {
> @@ -427,7 +427,7 @@ static int mscan_rx_poll(struct napi_struct *napi, int quota)
>   		skb = alloc_can_skb(dev,&frame);
>   		if (!skb) {
>   			if (printk_ratelimit())
> -				dev_notice(dev->dev.parent, "packet dropped\n");
> +				netdev_notice(dev, "packet dropped\n");
>   			stats->rx_dropped++;
>   			out_8(&regs->canrflg, canrflg);
>   			continue;
> @@ -551,8 +551,7 @@ static int mscan_do_set_bittiming(struct net_device *dev)
>   		BTR1_SET_TSEG2(bt->phase_seg2) |
>   		BTR1_SET_SAM(priv->can.ctrlmode&  CAN_CTRLMODE_3_SAMPLES));
>
> -	dev_info(dev->dev.parent, "setting BTR0=0x%02x BTR1=0x%02x\n",
> -		btr0, btr1);
> +	netdev_info(dev, "setting BTR0=0x%02x BTR1=0x%02x\n", btr0, btr1);
>
>   	out_8(&regs->canbtr0, btr0);
>   	out_8(&regs->canbtr1, btr1);
> @@ -575,7 +574,7 @@ static int mscan_open(struct net_device *dev)
>
>   	ret = request_irq(dev->irq, mscan_isr, 0, dev->name, dev);
>   	if (ret<  0) {
> -		dev_err(dev->dev.parent, "failed to attach interrupt\n");
> +		netdev_err(dev, "failed to attach interrupt\n");
>   		goto exit_napi_disable;
>   	}
>
> diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
> index 04a3f1b..ebbcfca 100644
> --- a/drivers/net/can/sja1000/sja1000.c
> +++ b/drivers/net/can/sja1000/sja1000.c
> @@ -128,7 +128,7 @@ static void set_reset_mode(struct net_device *dev)
>   		status = priv->read_reg(priv, REG_MOD);
>   	}
>
> -	dev_err(dev->dev.parent, "setting SJA1000 into reset mode failed!\n");
> +	netdev_err(dev, "setting SJA1000 into reset mode failed!\n");
>   }
>
>   static void set_normal_mode(struct net_device *dev)
> @@ -156,7 +156,7 @@ static void set_normal_mode(struct net_device *dev)
>   		status = priv->read_reg(priv, REG_MOD);
>   	}
>
> -	dev_err(dev->dev.parent, "setting SJA1000 into normal mode failed!\n");
> +	netdev_err(dev, "setting SJA1000 into normal mode failed!\n");
>   }
>
>   static void sja1000_start(struct net_device *dev)
> @@ -209,8 +209,7 @@ static int sja1000_set_bittiming(struct net_device *dev)
>   	if (priv->can.ctrlmode&  CAN_CTRLMODE_3_SAMPLES)
>   		btr1 |= 0x80;
>
> -	dev_info(dev->dev.parent,
> -		 "setting BTR0=0x%02x BTR1=0x%02x\n", btr0, btr1);
> +	netdev_info(dev, "setting BTR0=0x%02x BTR1=0x%02x\n", btr0, btr1);
>
>   	priv->write_reg(priv, REG_BTR0, btr0);
>   	priv->write_reg(priv, REG_BTR1, btr1);
> @@ -378,7 +377,7 @@ static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
>
>   	if (isrc&  IRQ_DOI) {
>   		/* data overrun interrupt */
> -		dev_dbg(dev->dev.parent, "data overrun interrupt\n");
> +		netdev_dbg(dev, "data overrun interrupt\n");
>   		cf->can_id |= CAN_ERR_CRTL;
>   		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
>   		stats->rx_over_errors++;
> @@ -388,7 +387,7 @@ static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
>
>   	if (isrc&  IRQ_EI) {
>   		/* error warning interrupt */
> -		dev_dbg(dev->dev.parent, "error warning interrupt\n");
> +		netdev_dbg(dev, "error warning interrupt\n");
>
>   		if (status&  SR_BS) {
>   			state = CAN_STATE_BUS_OFF;
> @@ -429,7 +428,7 @@ static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
>   	}
>   	if (isrc&  IRQ_EPI) {
>   		/* error passive interrupt */
> -		dev_dbg(dev->dev.parent, "error passive interrupt\n");
> +		netdev_dbg(dev, "error passive interrupt\n");
>   		if (status&  SR_ES)
>   			state = CAN_STATE_ERROR_PASSIVE;
>   		else
> @@ -437,7 +436,7 @@ static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
>   	}
>   	if (isrc&  IRQ_ALI) {
>   		/* arbitration lost interrupt */
> -		dev_dbg(dev->dev.parent, "arbitration lost interrupt\n");
> +		netdev_dbg(dev, "arbitration lost interrupt\n");
>   		alc = priv->read_reg(priv, REG_ALC);
>   		priv->can.can_stats.arbitration_lost++;
>   		stats->tx_errors++;
> @@ -495,7 +494,7 @@ irqreturn_t sja1000_interrupt(int irq, void *dev_id)
>   		status = priv->read_reg(priv, REG_SR);
>
>   		if (isrc&  IRQ_WUI)
> -			dev_warn(dev->dev.parent, "wakeup interrupt\n");
> +			netdev_warn(dev, "wakeup interrupt\n");
>
>   		if (isrc&  IRQ_TI) {
>   			/* transmission complete interrupt */
> @@ -522,7 +521,7 @@ irqreturn_t sja1000_interrupt(int irq, void *dev_id)
>   		priv->post_irq(priv);
>
>   	if (n>= SJA1000_MAX_IRQ)
> -		dev_dbg(dev->dev.parent, "%d messages handled in ISR", n);
> +		netdev_dbg(dev, "%d messages handled in ISR", n);
>
>   	return (n) ? IRQ_HANDLED : IRQ_NONE;
>   }
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index df809e3..d50e5e0 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -306,7 +306,7 @@ static int ti_hecc_set_btc(struct ti_hecc_priv *priv)
>   		if (bit_timing->brp>  4)
>   			can_btc |= HECC_CANBTC_SAM;
>   		else
> -			dev_warn(priv->ndev->dev.parent, "WARN: Triple" \
> +			netdev_warn(priv->ndev, "WARN: Triple"
>   				"sampling not set due to h/w limitations");
>   	}
>   	can_btc |= ((bit_timing->sjw - 1)&  0x3)<<  8;
> @@ -315,7 +315,7 @@ static int ti_hecc_set_btc(struct ti_hecc_priv *priv)
>   	/* ERM being set to 0 by default meaning resync at falling edge */
>
>   	hecc_write(priv, HECC_CANBTC, can_btc);
> -	dev_info(priv->ndev->dev.parent, "setting CANBTC=%#x\n", can_btc);
> +	netdev_info(priv->ndev, "setting CANBTC=%#x\n", can_btc);
>
>   	return 0;
>   }
> @@ -332,7 +332,7 @@ static void ti_hecc_reset(struct net_device *ndev)
>   	u32 cnt;
>   	struct ti_hecc_priv *priv = netdev_priv(ndev);
>
> -	dev_dbg(ndev->dev.parent, "resetting hecc ...\n");
> +	netdev_dbg(ndev, "resetting hecc ...\n");
>   	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_SRES);
>
>   	/* Set change control request and wait till enabled */
> @@ -496,7 +496,7 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
>   	if (unlikely(hecc_read(priv, HECC_CANME)&  mbx_mask)) {
>   		spin_unlock_irqrestore(&priv->mbx_lock, flags);
>   		netif_stop_queue(ndev);
> -		dev_err(priv->ndev->dev.parent,
> +		dev_err(priv->ndev,
>   			"BUG: TX mbx not ready tx_head=%08X, tx_tail=%08X\n",
>   			priv->tx_head, priv->tx_tail);
>   		return NETDEV_TX_BUSY;
> @@ -550,7 +550,7 @@ static int ti_hecc_rx_pkt(struct ti_hecc_priv *priv, int mbxno)
>   	skb = alloc_can_skb(priv->ndev,&cf);
>   	if (!skb) {
>   		if (printk_ratelimit())
> -			dev_err(priv->ndev->dev.parent,
> +			netdev_err(priv->ndev,
>   				"ti_hecc_rx_pkt: alloc_can_skb() failed\n");
>   		return -ENOMEM;
>   	}
> @@ -668,7 +668,7 @@ static int ti_hecc_error(struct net_device *ndev, int int_status,
>   	skb = alloc_can_err_skb(ndev,&cf);
>   	if (!skb) {
>   		if (printk_ratelimit())
> -			dev_err(priv->ndev->dev.parent,
> +			netdev_err(priv->ndev,
>   				"ti_hecc_error: alloc_can_err_skb() failed\n");
>   		return -ENOMEM;
>   	}
> @@ -684,7 +684,7 @@ static int ti_hecc_error(struct net_device *ndev, int int_status,
>   				cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
>   		}
>   		hecc_set_bit(priv, HECC_CANES, HECC_CANES_EW);
> -		dev_dbg(priv->ndev->dev.parent, "Error Warning interrupt\n");
> +		netdev_dbg(priv->ndev, "Error Warning interrupt\n");
>   		hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
>   	}
>
> @@ -699,7 +699,7 @@ static int ti_hecc_error(struct net_device *ndev, int int_status,
>   				cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
>   		}
>   		hecc_set_bit(priv, HECC_CANES, HECC_CANES_EP);
> -		dev_dbg(priv->ndev->dev.parent, "Error passive interrupt\n");
> +		netdev_dbg(priv->ndev, "Error passive interrupt\n");
>   		hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
>   	}
>
> @@ -824,7 +824,7 @@ static int ti_hecc_open(struct net_device *ndev)
>   	err = request_irq(ndev->irq, ti_hecc_interrupt, IRQF_SHARED,
>   			ndev->name, ndev);
>   	if (err) {
> -		dev_err(ndev->dev.parent, "error requesting interrupt\n");
> +		netdev_err(ndev, "error requesting interrupt\n");
>   		return err;
>   	}
>
> @@ -833,7 +833,7 @@ static int ti_hecc_open(struct net_device *ndev)
>   	/* Open common can device */
>   	err = open_candev(ndev);
>   	if (err) {
> -		dev_err(ndev->dev.parent, "open_candev() failed %d\n", err);
> +		netdev_err(ndev, "open_candev() failed %d\n", err);
>   		ti_hecc_transceiver_switch(priv, 0);
>   		free_irq(ndev->irq, ndev);
>   		return err;
> diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
> index a72c7bf..bf088b5 100644
> --- a/drivers/net/can/usb/ems_usb.c
> +++ b/drivers/net/can/usb/ems_usb.c
> @@ -288,8 +288,7 @@ static void ems_usb_read_interrupt_callback(struct urb *urb)
>   		return;
>
>   	default:
> -		dev_info(netdev->dev.parent, "Rx interrupt aborted %d\n",
> -			 urb->status);
> +		netdev_info(netdev, "Rx interrupt aborted %d\n", urb->status);
>   		break;
>   	}
>
> @@ -298,8 +297,7 @@ static void ems_usb_read_interrupt_callback(struct urb *urb)
>   	if (err == -ENODEV)
>   		netif_device_detach(netdev);
>   	else if (err)
> -		dev_err(netdev->dev.parent,
> -			"failed resubmitting intr urb: %d\n", err);
> +		netdev_err(netdev, "failed resubmitting intr urb: %d\n", err);
>   }
>
>   static void ems_usb_rx_can_msg(struct ems_usb *dev, struct ems_cpc_msg *msg)
> @@ -431,8 +429,7 @@ static void ems_usb_read_bulk_callback(struct urb *urb)
>   		return;
>
>   	default:
> -		dev_info(netdev->dev.parent, "Rx URB aborted (%d)\n",
> -			 urb->status);
> +		netdev_info(netdev, "Rx URB aborted (%d)\n", urb->status);
>   		goto resubmit_urb;
>   	}
>
> @@ -477,7 +474,7 @@ static void ems_usb_read_bulk_callback(struct urb *urb)
>   			msg_count--;
>
>   			if (start>  urb->transfer_buffer_length) {
> -				dev_err(netdev->dev.parent, "format error\n");
> +				netdev_err(netdev, "format error\n");
>   				break;
>   			}
>   		}
> @@ -493,8 +490,8 @@ resubmit_urb:
>   	if (retval == -ENODEV)
>   		netif_device_detach(netdev);
>   	else if (retval)
> -		dev_err(netdev->dev.parent,
> -			"failed resubmitting read bulk urb: %d\n", retval);
> +		netdev_err(netdev,
> +			   "failed resubmitting read bulk urb: %d\n", retval);
>   }
>
>   /*
> @@ -521,8 +518,7 @@ static void ems_usb_write_bulk_callback(struct urb *urb)
>   		return;
>
>   	if (urb->status)
> -		dev_info(netdev->dev.parent, "Tx URB aborted (%d)\n",
> -			 urb->status);
> +		netdev_info(netdev, "Tx URB aborted (%d)\n", urb->status);
>
>   	netdev->trans_start = jiffies;
>
> @@ -605,16 +601,14 @@ static int ems_usb_start(struct ems_usb *dev)
>   		/* create a URB, and a buffer for it */
>   		urb = usb_alloc_urb(0, GFP_KERNEL);
>   		if (!urb) {
> -			dev_err(netdev->dev.parent,
> -				"No memory left for URBs\n");
> +			netdev_err(netdev, "No memory left for URBs\n");
>   			return -ENOMEM;
>   		}
>
>   		buf = usb_alloc_coherent(dev->udev, RX_BUFFER_SIZE, GFP_KERNEL,
>   					&urb->transfer_dma);
>   		if (!buf) {
> -			dev_err(netdev->dev.parent,
> -				"No memory left for USB buffer\n");
> +			netdev_err(netdev, "No memory left for USB buffer\n");
>   			usb_free_urb(urb);
>   			return -ENOMEM;
>   		}
> @@ -642,13 +636,13 @@ static int ems_usb_start(struct ems_usb *dev)
>
>   	/* Did we submit any URBs */
>   	if (i == 0) {
> -		dev_warn(netdev->dev.parent, "couldn't setup read URBs\n");
> +		netdev_warn(netdev, "couldn't setup read URBs\n");
>   		return err;
>   	}
>
>   	/* Warn if we've couldn't transmit all the URBs */
>   	if (i<  MAX_RX_URBS)
> -		dev_warn(netdev->dev.parent, "rx performance may be slow\n");
> +		netdev_warn(netdev, "rx performance may be slow\n");
>
>   	/* Setup and start interrupt URB */
>   	usb_fill_int_urb(dev->intr_urb, dev->udev,
> @@ -662,8 +656,7 @@ static int ems_usb_start(struct ems_usb *dev)
>   		if (err == -ENODEV)
>   			netif_device_detach(dev->netdev);
>
> -		dev_warn(netdev->dev.parent, "intr URB submit failed: %d\n",
> -			 err);
> +		netdev_warn(netdev, "intr URB submit failed: %d\n", err);
>
>   		return err;
>   	}
> @@ -695,7 +688,7 @@ failed:
>   	if (err == -ENODEV)
>   		netif_device_detach(dev->netdev);
>
> -	dev_warn(netdev->dev.parent, "couldn't submit control: %d\n", err);
> +	netdev_warn(netdev, "couldn't submit control: %d\n", err);
>
>   	return err;
>   }
> @@ -735,8 +728,7 @@ static int ems_usb_open(struct net_device *netdev)
>   		if (err == -ENODEV)
>   			netif_device_detach(dev->netdev);
>
> -		dev_warn(netdev->dev.parent, "couldn't start device: %d\n",
> -			 err);
> +		netdev_warn(netdev, "couldn't start device: %d\n", err);
>
>   		close_candev(netdev);
>
> @@ -769,13 +761,13 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
>   	/* create a URB, and a buffer for it, and copy the data to the URB */
>   	urb = usb_alloc_urb(0, GFP_ATOMIC);
>   	if (!urb) {
> -		dev_err(netdev->dev.parent, "No memory left for URBs\n");
> +		netdev_err(netdev, "No memory left for URBs\n");
>   		goto nomem;
>   	}
>
>   	buf = usb_alloc_coherent(dev->udev, size, GFP_ATOMIC,&urb->transfer_dma);
>   	if (!buf) {
> -		dev_err(netdev->dev.parent, "No memory left for USB buffer\n");
> +		netdev_err(netdev, "No memory left for USB buffer\n");
>   		usb_free_urb(urb);
>   		goto nomem;
>   	}
> @@ -818,7 +810,7 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
>   		usb_unanchor_urb(urb);
>   		usb_free_coherent(dev->udev, size, buf, urb->transfer_dma);
>
> -		dev_warn(netdev->dev.parent, "couldn't find free context\n");
> +		netdev_warn(netdev, "couldn't find free context\n");
>
>   		return NETDEV_TX_BUSY;
>   	}
> @@ -849,7 +841,7 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
>   		if (err == -ENODEV) {
>   			netif_device_detach(netdev);
>   		} else {
> -			dev_warn(netdev->dev.parent, "failed tx_urb %d\n", err);
> +			netdev_warn(netdev, "failed tx_urb %d\n", err);
>
>   			stats->tx_dropped++;
>   		}
> @@ -889,7 +881,7 @@ static int ems_usb_close(struct net_device *netdev)
>
>   	/* Set CAN controller to reset mode */
>   	if (ems_usb_write_mode(dev, SJA1000_MOD_RM))
> -		dev_warn(netdev->dev.parent, "couldn't stop device");
> +		netdev_warn(netdev, "couldn't stop device");
>
>   	close_candev(netdev);
>
> @@ -926,7 +918,7 @@ static int ems_usb_set_mode(struct net_device *netdev, enum can_mode mode)
>   	switch (mode) {
>   	case CAN_MODE_START:
>   		if (ems_usb_write_mode(dev, SJA1000_MOD_NORMAL))
> -			dev_warn(netdev->dev.parent, "couldn't start device");
> +			netdev_warn(netdev, "couldn't start device");
>
>   		if (netif_queue_stopped(netdev))
>   			netif_wake_queue(netdev);
> @@ -951,8 +943,7 @@ static int ems_usb_set_bittiming(struct net_device *netdev)
>   	if (dev->can.ctrlmode&  CAN_CTRLMODE_3_SAMPLES)
>   		btr1 |= 0x80;
>
> -	dev_info(netdev->dev.parent, "setting BTR0=0x%02x BTR1=0x%02x\n",
> -		 btr0, btr1);
> +	netdev_info(netdev, "setting BTR0=0x%02x BTR1=0x%02x\n", btr0, btr1);
>
>   	dev->active_params.msg.can_params.cc_params.sja1000.btr0 = btr0;
>   	dev->active_params.msg.can_params.cc_params.sja1000.btr1 = btr1;
> @@ -1057,15 +1048,13 @@ static int ems_usb_probe(struct usb_interface *intf,
>
>   	err = ems_usb_command_msg(dev,&dev->active_params);
>   	if (err) {
> -		dev_err(netdev->dev.parent,
> -			"couldn't initialize controller: %d\n", err);
> +		netdev_err(netdev, "couldn't initialize controller: %d\n", err);
>   		goto cleanup_tx_msg_buffer;
>   	}
>
>   	err = register_candev(netdev);
>   	if (err) {
> -		dev_err(netdev->dev.parent,
> -			"couldn't register CAN device: %d\n", err);
> +		netdev_err(netdev, "couldn't register CAN device: %d\n", err);
>   		goto cleanup_tx_msg_buffer;
>   	}
>
> diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
> index eb8b0e6..6f3fafb 100644
> --- a/drivers/net/can/usb/esd_usb2.c
> +++ b/drivers/net/can/usb/esd_usb2.c
> @@ -470,8 +470,7 @@ static void esd_usb2_write_bulk_callback(struct urb *urb)
>   		return;
>
>   	if (urb->status)
> -		dev_info(netdev->dev.parent, "Tx URB aborted (%d)\n",
> -			 urb->status);
> +		netdev_info(netdev, "Tx URB aborted (%d)\n", urb->status);
>
>   	netdev->trans_start = jiffies;
>   }
> @@ -651,7 +650,7 @@ failed:
>   	if (err == -ENODEV)
>   		netif_device_detach(netdev);
>
> -	dev_err(netdev->dev.parent, "couldn't start device: %d\n", err);
> +	netdev_err(netdev, "couldn't start device: %d\n", err);
>
>   	return err;
>   }
> @@ -687,8 +686,7 @@ static int esd_usb2_open(struct net_device *netdev)
>   	/* finally start device */
>   	err = esd_usb2_start(priv);
>   	if (err) {
> -		dev_warn(netdev->dev.parent,
> -			 "couldn't start device: %d\n", err);
> +		netdev_warn(netdev, "couldn't start device: %d\n", err);
>   		close_candev(netdev);
>   		return err;
>   	}
> @@ -721,7 +719,7 @@ static netdev_tx_t esd_usb2_start_xmit(struct sk_buff *skb,
>   	/* create a URB, and a buffer for it, and copy the data to the URB */
>   	urb = usb_alloc_urb(0, GFP_ATOMIC);
>   	if (!urb) {
> -		dev_err(netdev->dev.parent, "No memory left for URBs\n");
> +		netdev_err(netdev, "No memory left for URBs\n");
>   		stats->tx_dropped++;
>   		dev_kfree_skb(skb);
>   		goto nourbmem;
> @@ -730,7 +728,7 @@ static netdev_tx_t esd_usb2_start_xmit(struct sk_buff *skb,
>   	buf = usb_alloc_coherent(dev->udev, size, GFP_ATOMIC,
>   				&urb->transfer_dma);
>   	if (!buf) {
> -		dev_err(netdev->dev.parent, "No memory left for USB buffer\n");
> +		netdev_err(netdev, "No memory left for USB buffer\n");
>   		stats->tx_dropped++;
>   		dev_kfree_skb(skb);
>   		goto nobufmem;
> @@ -766,7 +764,7 @@ static netdev_tx_t esd_usb2_start_xmit(struct sk_buff *skb,
>   	 * This may never happen.
>   	 */
>   	if (!context) {
> -		dev_warn(netdev->dev.parent, "couldn't find free context\n");
> +		netdev_warn(netdev, "couldn't find free context\n");
>   		ret = NETDEV_TX_BUSY;
>   		goto releasebuf;
>   	}
> @@ -806,7 +804,7 @@ static netdev_tx_t esd_usb2_start_xmit(struct sk_buff *skb,
>   		if (err == -ENODEV)
>   			netif_device_detach(netdev);
>   		else
> -			dev_warn(netdev->dev.parent, "failed tx_urb %d\n", err);
> +			netdev_warn(netdev, "failed tx_urb %d\n", err);
>
>   		goto releasebuf;
>   	}
> @@ -845,7 +843,7 @@ static int esd_usb2_close(struct net_device *netdev)
>   	for (i = 0; i<= ESD_MAX_ID_SEGMENT; i++)
>   		msg.msg.filter.mask[i] = 0;
>   	if (esd_usb2_send_msg(priv->usb2,&msg)<  0)
> -		dev_err(netdev->dev.parent, "sending idadd message failed\n");
> +		netdev_err(netdev, "sending idadd message failed\n");
>
>   	/* set CAN controller to reset mode */
>   	msg.msg.hdr.len = 2;
> @@ -854,7 +852,7 @@ static int esd_usb2_close(struct net_device *netdev)
>   	msg.msg.setbaud.rsvd = 0;
>   	msg.msg.setbaud.baud = cpu_to_le32(ESD_USB2_NO_BAUDRATE);
>   	if (esd_usb2_send_msg(priv->usb2,&msg)<  0)
> -		dev_err(netdev->dev.parent, "sending setbaud message failed\n");
> +		netdev_err(netdev, "sending setbaud message failed\n");
>
>   	priv->can.state = CAN_STATE_STOPPED;
>
> @@ -910,7 +908,7 @@ static int esd_usb2_set_bittiming(struct net_device *netdev)
>   	msg.msg.setbaud.rsvd = 0;
>   	msg.msg.setbaud.baud = cpu_to_le32(canbtr);
>
> -	dev_info(netdev->dev.parent, "setting BTR=%#x\n", canbtr);
> +	netdev_info(netdev, "setting BTR=%#x\n", canbtr);
>
>   	return esd_usb2_send_msg(priv->usb2,&msg);
>   }
> @@ -988,15 +986,14 @@ static int esd_usb2_probe_one_net(struct usb_interface *intf, int index)
>
>   	err = register_candev(netdev);
>   	if (err) {
> -		dev_err(&intf->dev,
> -			"couldn't register CAN device: %d\n", err);
> +		dev_err(&intf->dev, "couldn't register CAN device: %d\n", err);
>   		free_candev(netdev);
>   		err = -ENOMEM;
>   		goto done;
>   	}
>
>   	dev->nets[index] = priv;
> -	dev_info(netdev->dev.parent, "device %s registered\n", netdev->name);
> +	netdev_info(netdev, "device %s registered\n", netdev->name);
>
>   done:
>   	return err;
