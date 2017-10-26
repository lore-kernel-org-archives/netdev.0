From: Bhadram Varka <vbhadram@nvidia.com>
Subject: RE: [PATCH net] net: stmmac: First Queue must always be in DCB mode
Date: Thu, 26 Oct 2017 10:51:27 +0000
Message-ID: <c58a62cc2971476b95e34096eb32f852@bgmail102.nvidia.com>
References: <d0f29981af9cfc700709af274acd7dba4b2014a7.1509008601.git.joabreu@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Jose Abreu <Jose.Abreu@synopsys.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d0f29981af9cfc700709af274acd7dba4b2014a7.1509008601.git.joabreu@synopsys.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jose,

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Jose Abreu
> Sent: Thursday, October 26, 2017 2:37 PM
> To: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Cc: Jose Abreu <Jose.Abreu@synopsys.com>; Joao Pinto
> <Joao.Pinto@synopsys.com>; David S. Miller <davem@davemloft.net>;
> Giuseppe Cavallaro <peppe.cavallaro@st.com>; Alexandre Torgue
> <alexandre.torgue@st.com>
> Subject: [PATCH net] net: stmmac: First Queue must always be in DCB mode
> 
> According to DWMAC databook the first queue operating mode must always
> be in DCB.
> 
> As MTL_QUEUE_DCB = 1, we need to always set the first queue operating
> mode to DCB otherwise driver will think that queue is in AVB mode (because
> MTL_QUEUE_AVB = 0).
> 
> Signed-off-by: Jose Abreu <joabreu@synopsys.com>
> Cc: Joao Pinto <jpinto@synopsys.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre Torgue <alexandre.torgue@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 21f59fe..603225b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -150,6 +150,13 @@ static void stmmac_mtl_setup(struct
> platform_device *pdev,
>  	plat->rx_queues_to_use = 1;
>  	plat->tx_queues_to_use = 1;
> 
> +	/* First Queue must always be in DCB mode. As MTL_QUEUE_DCB =
> 1 we need
> +	 * to always set this, otherwise Queue will be classified as AVB
> +	 * (because MTL_QUEUE_AVB = 0).
> +	 */
Its better if we can check whether IP HW features (register - 0x120) supports the DCB or not. If yes, then set the DCB mode.
There is possibility that DCB feature not enable for few of the Synopsys IP's.

Thanks,
Bhadram.
