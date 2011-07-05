From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 3/6] r8169: adjust the settings about RxConfig
Date: Tue, 5 Jul 2011 20:55:34 +0200
Message-ID: <20110705185534.GC5105@electric-eye.fr.zoreil.com>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com> <1309859095-32031-3-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309859095-32031-3-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index cdbbe47..3aeae68 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -71,7 +71,7 @@ static const int multicast_filter_limit = 32;
>  
>  #define MAX_READ_REQUEST_SHIFT	12
>  #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
> -#define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
> +#define RX_DMA_BURST	7	/* Maximum PCI burst, '7' is Unlimited */
>  #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
>  #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
>  #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
> @@ -272,9 +272,6 @@ enum rtl_registers {
>  	IntrStatus	= 0x3e,
>  	TxConfig	= 0x40,
>  	RxConfig	= 0x44,
> -
> -#define RTL_RX_CONFIG_MASK		0xff7e1880u
> -

Nit: could you remove RxCfgFIFOShift and add something like 

#define RXCFG_FIFO_SHIFT	13
				/* No threshold before first PCI xfer. */
#define RXCFG_FIFO_THRESH	(7 << RXCFG_FIFO_SHIFT)
#define RXCFG_DMA_SHIFT		8
				/* Unlimited maximum PCI burst. */
#define	RXCFG_DMA_BURST		(7 << RXCFG_DMA_SHIFT)

(and move both RX128_INT_EN and RX_MULTI_EN near RxConfig in patch #1)

-- 
Ueimor
