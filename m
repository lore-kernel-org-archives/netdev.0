From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 20:01:47 +0100
Message-ID: <AANLkTimFcEC0oXJGnJ7HQKLB9thfuWHeWSYSMCGR=hWJ@mail.gmail.com>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	<1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com, joe@perches.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/1/20 Po-Yu Chuang <ratbert.chuang@gmail.com>:
[...]
> +/*******************************************************************=
***********
> + * internal functions (receive descriptor)
> + *******************************************************************=
**********/
> +static bool ftmac100_rxdes_first_segment(struct ftmac100_rxdes *rxde=
s)
> +{
> + =A0 =A0 =A0 return le32_to_cpu(rxdes->rxdes0) & FTMAC100_RXDES0_FRS=
;
> +}
> +
> +static bool ftmac100_rxdes_last_segment(struct ftmac100_rxdes *rxdes=
)
> +{
> + =A0 =A0 =A0 return le32_to_cpu(rxdes->rxdes0) & FTMAC100_RXDES0_LRS=
;
> +}
> +
[...]

You can change these and similar functions to use:

rxdes->rxdes0 & cpu_to_le32(FTMAC100_RXDES0_LRS)

This will be subject to constant folding by compiler and produce
better code for big-endian arches.

Best Regards,
Micha=B3 Miros=B3aw
