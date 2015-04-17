From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2] net: dsa: use DEVICE_ATTR_RW to declare temp1_max
Date: Fri, 17 Apr 2015 12:40:06 -0700
Message-ID: <20150417194006.GA9538@roeck-us.net>
References: <1429297945-26651-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:44263 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbDQTkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 15:40:24 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YjC7i-002TNB-Vw
	for netdev@vger.kernel.org; Fri, 17 Apr 2015 19:40:23 +0000
Content-Disposition: inline
In-Reply-To: <1429297945-26651-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2015 at 03:12:25PM -0400, Vivien Didelot wrote:
> Since commit da4759c (sysfs: Use only return value from is_visible for
> the file mode), it is possible to reduce the permissions of a file.
> 
> So declare temp1_max with the DEVICE_ATTR_RW macro and remove the write
> permission in dsa_hwmon_attrs_visible if set_temp_limit isn't provided.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Looks good.

Reviewed-by: Guenter Roeck <linux@roeck-us.net>

> ---
>  net/dsa/dsa.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 5eaadab..079a224 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -124,7 +124,7 @@ static ssize_t temp1_max_store(struct device *dev,
>  
>  	return count;
>  }
> -static DEVICE_ATTR(temp1_max, S_IRUGO, temp1_max_show, temp1_max_store);
> +static DEVICE_ATTR_RW(temp1_max);
>  
>  static ssize_t temp1_max_alarm_show(struct device *dev,
>  				    struct device_attribute *attr, char *buf)
> @@ -159,8 +159,8 @@ static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
>  	if (index == 1) {
>  		if (!drv->get_temp_limit)
>  			mode = 0;
> -		else if (drv->set_temp_limit)
> -			mode |= S_IWUSR;
> +		else if (!drv->set_temp_limit)
> +			mode &= ~S_IWUSR;
>  	} else if (index == 2 && !drv->get_temp_alarm) {
>  		mode = 0;
>  	}
> -- 
> 2.3.5
> 
