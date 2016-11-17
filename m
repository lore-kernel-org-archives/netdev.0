From: Rafal Ozieblo <rafalo@cadence.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Thu, 17 Nov 2016 11:50:28 +0000
Message-ID: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
Reply-To: Rafal Ozieblo <rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I think, there could a bug in your patch.

> +
> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> +             dmacfg |=3D GEM_BIT(ADDR64);
> +#endif

You enable 64 bit addressing (64b dma bus width) always when appropriate ar=
chitecture config option is enabled.
But there are some legacy controllers which do not support that feature. Ac=
cording Cadence hardware team:
"64 bit addressing was added in July 2013. Earlier version do not have it.
This feature was enhanced in release August 2014 to have separate upper add=
ress values for transmit and receive."

> /* Bitfields in NSR */
> @@ -474,6 +479,10 @@
>  struct macb_dma_desc {
 >	u32	addr;
>  	u32	ctrl;
> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> +	u32     addrh;
> +	u32     resvd;
> +#endif
>  };

It will not work for legacy hardware. Old descriptor is 2 words wide, the n=
ew one is 4 words wide.
If you enable CONFIG_ARCH_DMA_ADDR_T_64BIT but hardware doesn't support it =
at all,
you will miss every second descriptor.

Regards,
Rafal

=A0
