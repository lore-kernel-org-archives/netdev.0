From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH] stmmac: extend DMA initialization delay to 2.5 seconds
Date: Thu, 5 Jun 2014 15:30:15 +0100
Message-ID: <20140605143015.GD24240@lee--X1>
References: <1401973080-10085-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hans de Goede <hdegoede@redhat.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Chen-Yu Tsai <wens@csie.org>, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	srinivas.kandagatla@linaro.org, kernel@stlinux.com
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1401973080-10085-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+Srinivas and the ST list.

> On some platforms existing 100 msecond delay is not enough for DMA bl=
ock to
> recover after reset. This is because MAC DMA waits for all PHY input =
clocks
> to present and depending on the board reset bit deassertion may take =
much
> longer than previously used 100 milliseconds
>=20
> I have a board that requires more than 2 seconds for DMA to zero "res=
et" bit.
> If for other boards it's still not long enough this value should be e=
xtended
> once again.
>=20
> In the same change I convert "mdelay" to "msleep" to make CPU availab=
le for
> other processes during DMA init delay which is especially useful in c=
ase of
> delay for a few seconds.
>=20
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
>=20
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Hans de Goede <hdegoede@redhat.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Chen-Yu Tsai <wens@csie.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: devicetree@vger.kernel.org
> Cc: Vineet Gupta <vgupta@synopsys.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c | 4 ++--
>  drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c  | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/dr=
ivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> index 0c2058a..f713ea7 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> @@ -39,11 +39,11 @@ static int dwmac1000_dma_init(void __iomem *ioadd=
r, int pbl, int fb, int mb,
>  	/* DMA SW reset */
>  	value |=3D DMA_BUS_MODE_SFT_RESET;
>  	writel(value, ioaddr + DMA_BUS_MODE);
> -	limit =3D 10;
> +	limit =3D 100;
>  	while (limit--) {
>  		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
>  			break;
> -		mdelay(10);
> +		msleep(25);
>  	}
>  	if (limit < 0)
>  		return -EBUSY;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/dri=
vers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> index 7d1dce9..043585f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> @@ -41,11 +41,11 @@ static int dwmac100_dma_init(void __iomem *ioaddr=
, int pbl, int fb, int mb,
>  	/* DMA SW reset */
>  	value |=3D DMA_BUS_MODE_SFT_RESET;
>  	writel(value, ioaddr + DMA_BUS_MODE);
> -	limit =3D 10;
> +	limit =3D 100;
>  	while (limit--) {
>  		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
>  			break;
> -		mdelay(10);
> +		msleep(25);
>  	}
>  	if (limit < 0)
>  		return -EBUSY;

--=20
Lee Jones
Linaro STMicroelectronics Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
