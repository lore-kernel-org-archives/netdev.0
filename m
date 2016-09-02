From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [Patch v4 09/12] net: ethernet: xilinx: Generate random mac if
 none found
Date: Fri, 2 Sep 2016 09:08:25 +0200
Message-ID: <97b7241b-941e-006c-498f-2dbffdb9d951@xilinx.com>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-10-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <michal.simek@xilinx.com>,
        <netdev@vger.kernel.org>
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1472748665-47774-10-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 1.9.2016 18:51, Zubair Lutfullah Kakakhel wrote:
> At the moment, if the emaclite device doesn't find a mac address
> from any source, it simply uses 0x0 with a warning printed.
> 
> Instead of using a 0x0 mac address, use a randomly generated one.
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> 
> ---
> V3 -> V4
> Curly braces after if check for correct styling
> 
> V2 -> V3
> No change
> 
> V1 -> V2
> New patch
> ---
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> index 3cee84a..efc8d2e 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1131,11 +1131,13 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
>  	lp->rx_ping_pong = get_bool(ofdev, "xlnx,rx-ping-pong");
>  	mac_address = of_get_mac_address(ofdev->dev.of_node);
>  
> -	if (mac_address)
> +	if (mac_address) {
>  		/* Set the MAC address. */
>  		memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
> -	else
> -		dev_warn(dev, "No MAC address found\n");
> +	} else {
> +		dev_warn(dev, "No MAC address found. Generating Random one\n");
> +		eth_hw_addr_random(ndev);
> +	}
>  
>  	/* Clear the Tx CSR's in case this is a restart */
>  	__raw_writel(0, lp->base_addr + XEL_TSR_OFFSET);
> 

You should remove these 2 emaclite patches and send them separately
because they should go via netdev tree.

Thanks,
Michal
