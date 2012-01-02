From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 2/4] net: ethernet: xilinx: Don't use NO_IRQ in xilinx
Date: Mon, 2 Jan 2012 01:21:24 -0700
Message-ID: <20120102082124.GD18381@ponder.secretlab.ca>
References: <1324477932-19262-1-git-send-email-monstr@monstr.eu>
 <1324477932-19262-2-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, Ryan Mallon <rmallon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1324477932-19262-2-git-send-email-monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2011 at 03:32:10PM +0100, Michal Simek wrote:
> Fix ll_temac and emaclite drivers. Only Microblaze and Xilinx PPC
> use then and both use NO_IRQ as 0. It will be removed in near future.
> 
> Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
> CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (commit_signer:7/10=70%)
> CC: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org> (commit_signer:1/10=10%)
> CC: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> CC: Ryan Mallon <rmallon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---

Acked-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>

>  drivers/net/ethernet/xilinx/ll_temac_main.c   |    2 +-
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
> index 2681b53..87775d7 100644
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -1077,7 +1077,7 @@ static int __devinit temac_of_probe(struct platform_device *op)
>  
>  	of_node_put(np); /* Finished with the DMA node; drop the reference */
>  
> -	if ((lp->rx_irq == NO_IRQ) || (lp->tx_irq == NO_IRQ)) {
> +	if (!lp->rx_irq || !lp->tx_irq) {
>  		dev_err(&op->dev, "could not determine irqs\n");
>  		rc = -ENOMEM;
>  		goto err_iounmap_2;
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> index 8018d7d..252edf7 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1129,7 +1129,7 @@ static int __devinit xemaclite_of_probe(struct platform_device *ofdev)
>  
>  	/* Get IRQ for the device */
>  	rc = of_irq_to_resource(ofdev->dev.of_node, 0, &r_irq);
> -	if (rc == NO_IRQ) {
> +	if (!rc) {
>  		dev_err(dev, "no IRQ found\n");
>  		return rc;
>  	}
> -- 
> 1.7.5.4
> 
