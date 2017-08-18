From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: stmmac: socfgpa: Ensure emac bit set in sys manager
 for MII/GMII/SGMII.
Date: Fri, 18 Aug 2017 12:58:30 +0300
Message-ID: <55cc4f69-95a4-65e9-234d-880bfcf1fed0@cogentembedded.com>
References: <1503039314-575-1-git-send-email-stephan.gatzka@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Stephan Gatzka <stephan.gatzka@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503039314-575-1-git-send-email-stephan.gatzka@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 8/18/2017 9:55 AM, Stephan Gatzka wrote:

> When using MII/GMII/SGMII in the Altera SoC, the phy needs to be
> wired through the FPGA. To ensure correct behavior, the appropriate
> bit in the System Manager FPGA Interface Group register needs to be
> set.
> 
> Signed-off-by: Stephan Gatzka <stephan.gatzka@gmail.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> index 17d4bba..d7c231b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> @@ -269,7 +269,10 @@ static int socfpga_dwmac_set_phy_mode(struct socfpga_dwmac *dwmac)
>   	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << reg_shift);
>   	ctrl |= val << reg_shift;
>   
> -	if (dwmac->f2h_ptp_ref_clk) {
> +	if ((dwmac->f2h_ptp_ref_clk) ||
> +	    (phymode == PHY_INTERFACE_MODE_MII) ||
> +	    (phymode == PHY_INTERFACE_MODE_GMII) ||
> +	    (phymode == PHY_INTERFACE_MODE_SGMII)) {

    Inner parens not needed at all (especially the first pair).

[...]

MBR, Sergei
