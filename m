From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH v3] net/smsc911x: add device tree probe support
Date: Thu, 8 Sep 2011 11:29:20 -0700
Message-ID: <20110908182920.GL2967@ponder.secretlab.ca>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
	<1312050360-15767-1-git-send-email-shawn.guo@linaro.org>
	<20110908145946.GE2070@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Dave Martin <dave.martin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110908145946.GE2070-5wv7dgnIgG8@public.gmane.org>
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

On Thu, Sep 08, 2011 at 03:59:46PM +0100, Dave Martin wrote:
> Hi Shawn,
> 
> On Sun, Jul 31, 2011 at 02:26:00AM +0800, Shawn Guo wrote:
> > It adds device tree probe support for smsc911x driver.
> > 
> > Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> > Cc: Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
> > Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > Reviewed-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> > ---
> > Changes since v2:
> >  * Fix a typo in smsc911x.txt
> > 
> > Changes since v1:
> >  * Instead of getting irq line from gpio number, it use irq domain
> >    to keep platform_get_resource(IORESOURCE_IRQ) works for dt too.
> >  * Use 'lan9115' the first model that smsc911x supports in the match
> >    table
> >  * Use reg-shift and reg-io-width which already used in of_serial for
> >    shift and access size binding
> 
> When using this patch with vexpress, I found that 16-bit register access
> mode doesn't seem to be getting set correctly.
> 
> Can you take a look at this additional patch and let me know if it looks
> correct?
> 
> Cheers
> ---Dave
> 
> From: Dave Martin <dave.martin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Date: Wed, 7 Sep 2011 17:26:31 +0100
> Subject: [PATCH] net/smsc911x: Correctly configure 16-bit register access from DT
> 
> The SMSC911X_USE_16BIT needs to be set when using 16-bit register
> access.  However, currently no flag is set if the DT doesn't specify
> 32-bit access.
> 
> This patch should set the SMSC911X_USE_16BIT flag in a manner consistent
> with the documented DT bindings.
> 
> Signed-off-by: Dave Martin <dave.martin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/smsc911x.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index 75c08a5..1a35c25 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -2121,6 +2121,8 @@ static int __devinit smsc911x_probe_config_dt(
>  	of_property_read_u32(np, "reg-io-width", &width);
>  	if (width == 4)
>  		config->flags |= SMSC911X_USE_32BIT;
> +	else
> +		config->flags |= SMSC911X_USE_16BIT;

Would it be better to do "else if (width == 2)"?  (completely
uninformed comment.  I've not looked at what the non-DT probe path
does on this driver.)

g.
