From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Tue, 30 May 2006 23:43:05 +0200
Message-ID: <20060530214305.GA27891@electric-eye.fr.zoreil.com>
References: <200605251716.00742.IvDoorn@gmail.com> <200605291758.07930.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:21933 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932497AbWE3VoY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 17:44:24 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200605291758.07930.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ivo van Doorn <ivdoorn@gmail.com> :
[...]
> diff --git a/drivers/input/misc/radiobtn.c b/drivers/input/misc/radiobtn.c
> new file mode 100644
> index 0000000..8d3b84a
> --- /dev/null
> +++ b/drivers/input/misc/radiobtn.c
[...]
> +void radiobtn_poll(unsigned long data)

static ?

[...]
> +int radiobtn_register_device(struct radio_button *radiobtn)
> +{
> +	int status;
> +
> +	/*
> +	 * Check if all mandatory fields have been set.
> +	 */
> +	if (radiobtn->poll_delay == 0 || radiobtn->button_poll == NULL)
> +		return -EINVAL;
> +
> +	/*
> +	 * Allocate, initialize and register input device.
> +	 */
> +	radiobtn->input_dev = input_allocate_device();
> +	if (!radiobtn->input_dev) {
> +		printk(KERN_ERR "Failed to allocate input device %s.\n",
> +			radiobtn->dev_name);
> +		return -ENOMEM;
> +	}
> +
> +	radiobtn->input_dev->name = "Radio button";
> +	radiobtn->input_dev->phys = strcat("radiobtn/", radiobtn->dev_name);

The first parameter of strcat() must be big enough to contain the whole
string.

-- 
Ueimor
