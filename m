From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Wed, 25 Jun 2014 08:58:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17264A8E@AcuExch.aculab.com>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Bhupesh Sharma' <bhupesh.sharma@freescale.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhupesh Sharma
> The FlexCAN IP on certain SoCs like (Freescale's LS1021A) is
> modelled in a big-endian fashion, i.e. the registers and the
> message buffers are organized in a BE way.
> 
> More details about the LS1021A SoC can be seen here:
> http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=LS1021A&nodeId=018rH325E4017B#
> 
> This patch ensures that the register read/write APIs are remodelled
> to address such cases, while ensuring that existing platforms (where
> the FlexCAN IP was modelled in LE way) do not break.
...
Munged to the new code....
> +static inline u32 flexcan_read(const struct flexcan_priv *priv,
> +			       void __iomem *addr)
>  {
> +	if (priv->devtype_data->module_is_big_endian)
> +		return ioread32be(addr);
> +	else
> +		return ioread32(addr);
>  }
> 
> +static inline void flexcan_write(const struct flexcan_priv *priv,
> +				 u32 val, void __iomem *addr)
>  {
> +	if (priv->devtype_data->module_is_big_endian)
> +		iowrite32be(val, addr);
> +	else
> +		iowrite32(val, addr);
>  }

Hmmm....
If performance ever matters that is horrid.
Probably to the point where making the functions 'inline' is just code bloat.

	David



