From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net: ethernet: renesas: sh_eth: add POST registers for
 rz
Date: Fri, 9 Sep 2016 20:49:23 +0300
Message-ID: <26fc49c2-fe99-2c30-93aa-01284377ae07@cogentembedded.com>
References: <20160907185709.24150-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Chris Brandt <chris.brandt@renesas.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160907185709.24150-1-chris.brandt@renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2016 09:57 PM, Chris Brandt wrote:

> Due to a mistake in the hardware manual, the FWSLC and POST1-4 registers
> were not documented and left out of the driver for RZ/A making the CAM
> feature non-operational.
> Additionally, when the offset values for POST1-4 are left blank, the driver
> attempts to set them using an offset of 0xFFFF which can cause a memory
> corruption or panic.
>
> This patch fixes the panic and properly enables CAM.
>
> Reported-by: Daniel Palmer <daniel@0x0f.com>
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
> ---
> v2:
> * POST registers really do exist, so just add them
> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 1f8240a..440ae27 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -2781,6 +2786,8 @@ static void sh_eth_tsu_init(struct sh_eth_private *mdp)
>  {
>  	if (sh_eth_is_rz_fast_ether(mdp)) {
>  		sh_eth_tsu_write(mdp, 0, TSU_TEN); /* Disable all CAM entry */
> +		sh_eth_tsu_write(mdp, TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL,
> +				 TSU_FWSLC);	/* Enable POST registers */
>  		return;
>  	}

    Wait, don't you also need to write 0s to the POST registers like done at 
the end of this function?

MBR, Sergei
