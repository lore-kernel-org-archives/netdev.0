From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3] smc91x: add devicetree support
Date: Tue, 25 Jan 2011 19:45:32 -0800 (PST)
Message-ID: <20110125.194532.71125517.davem@davemloft.net>
References: <1295939399-4197-1-git-send-email-thomas@wytron.com.tw>
	<1295957508-2701-1-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nios2-dev-1eJk0qcHJCcaeqlQEoCUNoJY59XmG8rH@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: thomas-SDxUXYEhEBiCuPEqFHbRBg@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1295957508-2701-1-git-send-email-thomas-SDxUXYEhEBiCuPEqFHbRBg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Chou <thomas-SDxUXYEhEBiCuPEqFHbRBg@public.gmane.org>
Date: Tue, 25 Jan 2011 20:11:48 +0800

> @@ -2394,6 +2395,13 @@ static int smc_drv_resume(struct device *dev)
>  	return 0;
>  }
>  
> +static const struct of_device_id smc91x_match[] = {
> +	{ .compatible = "smsc,lan91c94", },
> +	{ .compatible = "smsc,lan91c111", },
> +	{},
> +}
> +MODULE_DEVICE_TABLE(of, smc91x_match);
> +
>  static struct dev_pm_ops smc_drv_pm_ops = {
>  	.suspend	= smc_drv_suspend,
>  	.resume		= smc_drv_resume,

You should not unconditionally put the 'of' device table into the
module image, otherwise the module will be marked as being able to
support OF based devices but the code to support that won't actually
be comiled into the module.
