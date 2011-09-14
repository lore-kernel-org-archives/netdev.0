From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH] net/smsc911x: Correctly configure 16-bit register access
	from DT
Date: Wed, 14 Sep 2011 10:12:08 -0600
Message-ID: <20110914161208.GG3134@ponder.secretlab.ca>
References: <1315910969-4018-1-git-send-email-dave.martin@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
To: Dave Martin <dave.martin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1315910969-4018-1-git-send-email-dave.martin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
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

On Tue, Sep 13, 2011 at 11:49:29AM +0100, Dave Martin wrote:
> The SMSC911X_USE_16BIT needs to be set when using 16-bit register
> access.  However, currently no flag is set if the device tree
> doesn't specify 32-bit access, resulting in a BUG() and a non-
> working driver when 16-bit register access is configured for
> smsc911x in the DT.
> 
> This patch should set the SMSC911X_USE_16BIT flag in a manner
> consistent with the documented DT bindings.
> 
> Signed-off-by: Dave Martin <dave.martin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

Acked-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>

> ---
>  drivers/net/ethernet/smsc/smsc911x.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 788c4fd..a3aa4c0 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -2121,6 +2121,8 @@ static int __devinit smsc911x_probe_config_dt(
>  	of_property_read_u32(np, "reg-io-width", &width);
>  	if (width == 4)
>  		config->flags |= SMSC911X_USE_32BIT;
> +	else
> +		config->flags |= SMSC911X_USE_16BIT;
>  
>  	if (of_get_property(np, "smsc,irq-active-high", NULL))
>  		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
> -- 
> 1.7.4.1
> 
> _______________________________________________
> devicetree-discuss mailing list
> devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> https://lists.ozlabs.org/listinfo/devicetree-discuss
