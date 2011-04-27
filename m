From: "Subhasish Ghosh" <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 27 Apr 2011 18:38:19 +0530
Message-ID: <46D523E49EFF489F9B088AE7B9CD7286@subhasishg>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>	<1303474267-6344-2-git-send-email-subhasish@mistralsolutions.com>
	<4DB1A3B7.7060300@pengutronix.de> <4DB5D452.9050500@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	m-watkins-l0cyMroinI0@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4DB5D452.9050500-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

>
> - Use just *one* value per sysfs file

SG - I felt adding entry for each mbx_id will clutter the sysfs.
        Is it ok to do that.


>>> +static u32 pruss_intc_init[19][3] = {
>>> + {PRUSS_INTC_POLARITY0, PRU_INTC_REGMAP_MASK, 0xFFFFFFFF},
>>> + {PRUSS_INTC_POLARITY1, PRU_INTC_REGMAP_MASK, 0xFFFFFFFF},
>>> + {PRUSS_INTC_TYPE0, PRU_INTC_REGMAP_MASK, 0x1C000000},
>>> + {PRUSS_INTC_TYPE1, PRU_INTC_REGMAP_MASK, 0},
>>> + {PRUSS_INTC_GLBLEN, 0, 1},
>>> + {PRUSS_INTC_HOSTMAP0, PRU_INTC_REGMAP_MASK, 0x03020100},
>>> + {PRUSS_INTC_HOSTMAP1, PRU_INTC_REGMAP_MASK, 0x07060504},
>>> + {PRUSS_INTC_HOSTMAP2, PRU_INTC_REGMAP_MASK, 0x0000908},
>>> + {PRUSS_INTC_CHANMAP0, PRU_INTC_REGMAP_MASK, 0},
>>> + {PRUSS_INTC_CHANMAP8, PRU_INTC_REGMAP_MASK, 0x00020200},
>>> + {PRUSS_INTC_STATIDXCLR, 0, 32},
>>> + {PRUSS_INTC_STATIDXCLR, 0, 19},
>>> + {PRUSS_INTC_ENIDXSET, 0, 19},
>>> + {PRUSS_INTC_STATIDXCLR, 0, 18},
>>> + {PRUSS_INTC_ENIDXSET, 0, 18},
>>> + {PRUSS_INTC_STATIDXCLR, 0, 34},
>>> + {PRUSS_INTC_ENIDXSET, 0, 34},
>>> + {PRUSS_INTC_ENIDXSET, 0, 32},
>>> + {PRUSS_INTC_HOSTINTEN, 0, 5}
>>
>> please add ","
>
> Also a struct to describe each entry would improve readability.
> Then you could also use ARRAY_SIZE.

SG _ I could not follow this, are you recommending that I create a structure 
with three variables and then create
            an array for it.
something like:

const static struct [] = {
    {
    unsigned int reg_base;
    unsigned int reg_mask;
    unsigned int reg_val;
    },
...
};


>>> + value = (PRUSS_CAN_GPIO_SETUP_DELAY *
>>> + (priv->clk_freq_pru / 1000000) / 1000) /
>>> + PRUSS_CAN_DELAY_LOOP_LENGTH;
>
> This calculation looks delicate. 64-bit math would be safer.

SG - This one works fine. I am dividing it twice to avoid the problem.


>>> + pru_can_mask_ints(priv->dev, PRUSS_CAN_TX_PRU_1, false);
>>> + pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, false);
>>> + can_bus_off(ndev);
>>> + dev_dbg(priv->ndev->dev.parent, "Bus off mode\n");
>>> + }
>>> +
>>> + netif_rx(skb);
>
> You should use netif_receive_skb(skb) here as well.

SG - Ok, Will do.

>
> if (PRUSS_CAN_ISR_BIT_ESI &
>     priv->can_rx_cntx.intr_stat) {
>
> Is more readable.

SG - Ok, Will do.

>
>
>>> + pru_can_gbl_stat_get(priv->dev,
>>> + &priv->can_rx_cntx);
>>> + pru_can_err(ndev,
>>> + priv->can_rx_cntx.intr_stat,
>>> + priv->can_rx_cntx.gbl_stat);
>
> Please fix bogous indention.

SG - Ok, Will do.


>>> +
>>> + pdata = dev->platform_data;
>>> + if (!pdata) {
>>> + dev_err(&pdev->dev, "platform data not found\n");
>>> + return -EINVAL;
>>> + }
>>> + (pdata->setup)();
>>
>> no need fot the ( )

SG - Ok, Will do.

>>> + }
>>> +
>>> + priv->ndev = ndev;
>>> + priv->dev = dev;
>>> +
>>> + priv->can.bittiming_const = &pru_can_bittiming_const;
>>> + priv->can.do_set_bittiming = pru_can_set_bittiming;
>>> + priv->can.do_set_mode = pru_can_set_mode;
>>> + priv->can.do_get_state = pru_can_get_state;
>
> Please remove that callback. It's not needed as state changes are
> handled properly.
>

SG -- Ok, Will do
