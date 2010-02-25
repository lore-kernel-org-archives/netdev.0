From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices
 to sysfs
Date: Thu, 25 Feb 2010 14:55:33 -0800
Message-ID: <20100225225533.GA20900@kroah.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	jordan_hargrave@dell.com, sandeep_k_shandilya@dell.com,
	charles_rose@dell.com, shyam_iyer@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100225202941.GA19404@mock.linuxdev.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2010 at 02:29:42PM -0600, Narendra K wrote:
> --- a/drivers/base/bus.c
> +++ b/drivers/base/bus.c
> @@ -419,6 +419,11 @@ static int device_add_attrs(struct bus_type *bus, struct device *dev)
>  		return 0;
>  
>  	for (i = 0; attr_name(bus->dev_attrs[i]); i++) {
> +		/* if the device does not have an associated smbios string in the smbios table, do not create this attribute */ 
> +		if (!(strcmp(attr_name(bus->dev_attrs[i]), "smbiosname"))) {
> +			if (!smbiosname_string_is_valid(dev, NULL)) 
> +				continue;
> +		}

Um, no, you can not modify the driver core for stuff like this.  Do it
in your driver or class specific code, as that is where it is supposed
to be.

good luck,

greg k-h
