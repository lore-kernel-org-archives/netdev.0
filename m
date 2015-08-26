From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH -next v2 1/2] device property: Return -ENXIO if there is no suitable FW interface
Date: Thu, 27 Aug 2015 01:37:47 +0200
Message-ID: <3249742.BGnB0hq1eB@vostro.rjw.lan>
References: <1440620445-14413-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>, tony@atomide.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440620445-14413-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, August 26, 2015 01:20:44 PM Guenter Roeck wrote:
> Return -ENXIO if device property array access functions don't find
> a suitable firmware interface.
> 
> This lets drivers decide if they should use available platform data
> instead.
> 
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> v2: Added patch
> 
>  drivers/base/property.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/base/property.c b/drivers/base/property.c
> index 287704d680bf..9600b824d138 100644
> --- a/drivers/base/property.c
> +++ b/drivers/base/property.c
> @@ -69,6 +69,9 @@ static int pset_prop_read_array(struct property_set *pset, const char *name,
>  	struct property_entry *prop;
>  	unsigned int item_size;
>  
> +	if (!pset)
> +		return -ENXIO;
> +

This isn't exactly straightforward, because it relies on the fact that
pset_prop_read_array() is the last thing tried by FWNODE_PROP_READ_ARRAY()
and fwnode_property_read_string_array().  A comment about that might be
helpful.

Thanks,
Rafael
