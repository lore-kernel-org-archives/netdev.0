From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 2/2] net: dsa: register hwmon for any provided function
Date: Thu, 16 Apr 2015 14:26:38 -0700
Message-ID: <20150416212638.GB2587@roeck-us.net>
References: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1429209499-2447-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:58410 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbDPV1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 17:27:04 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YirJQ-004Fjp-4s
	for netdev@vger.kernel.org; Thu, 16 Apr 2015 21:27:04 +0000
Content-Disposition: inline
In-Reply-To: <1429209499-2447-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 02:38:19PM -0400, Vivien Didelot wrote:
> A switch driver may only provide one of the temperature limit accessors,
> or the temperature alarm getter. So register the hwmon subsystem if any
> of the related functions is provided.
> 
> Thus, check get_temp to set the visibility of temp1_input.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/dsa.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 67d2983..6b68994 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -157,6 +157,10 @@ static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
>  	umode_t mode = 0;
>  
>  	switch (index) {
> +	case 0: /* temp1_input */
> +		if (drv->get_temp)
> +			mode |= S_IRUGO;

This should be mandatory. Sorry, I don't really understand what you are
trying to accomplish here.

Can you give me a real world example where a chip would support setting
a limit but not reading it ?

Thanks,
Guenter

> +		break;
>  	case 1: /* temp1_max */
>  		if (drv->get_temp_limit)
>  			mode |= S_IRUGO;
> @@ -310,7 +314,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  	 * register with hardware monitoring subsystem.
>  	 * Treat registration error as non-fatal and ignore it.
>  	 */
> -	if (drv->get_temp) {
> +	if (drv->get_temp || drv->get_temp_limit || drv->set_temp_limit ||
> +	    drv->get_temp_alarm) {
>  		const char *netname = netdev_name(dst->master_netdev);
>  		char hname[IFNAMSIZ + 1];
>  		int i, j;
> -- 
> 2.3.5
> 
