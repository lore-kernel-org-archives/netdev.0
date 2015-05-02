From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] stmac: add dwmac glue for NXP 18xx/43xx family
Date: Sat, 02 May 2015 21:31:04 +0200
Message-ID: <3200125.o3jqXuyPfG@wuerfel>
References: <1430584842-23408-1-git-send-email-manabian@gmail.com>
 <1430584842-23408-2-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, Joachim Eastwood <manabian@gmail.com>,
 davem@davemloft.net, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1430584842-23408-2-git-send-email-manabian@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Saturday 02 May 2015 18:40:41 Joachim Eastwood wrote:
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -36,6 +36,7 @@ static const struct of_device_id stmmac_dt_ids[] = {
>         { .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
>         { .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
>         { .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
> +       { .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data},
>         { .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
>         { .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
>         { .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
> 

Any chance you could turn this around and do the probing in the normal
order, with a platform driver that registers to your compatible string
and calls into a common base module?

Unfortunately, something went wrong when we first started adding platform
specific hacks to the driver. I tried to fix it up back then, and IIRC
it was agreed that it should be changed but my patches for some reason
missed out on getting merged and the mistake propagated afterwards.

It should be fairly straightforward to split the probe function
into two and export a function that takes a device and a stmmac_of_data
pointer as arguments, and declare a module_platform_driver in your
code.

	Arnd
