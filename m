From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4] ptp: use kcalloc/kmallco_array when allocating arrays
Date: Tue, 14 Feb 2017 09:38:50 +0100
Message-ID: <20170214083850.GB8048@localhost.localdomain>
References: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
 <20170214035108.19622-2-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214035108.19622-2-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 07:51:06PM -0800, Dmitry Torokhov wrote:
> @@ -269,13 +269,13 @@ static int ptp_populate_pins(struct ptp_clock *ptp)
>  	struct ptp_clock_info *info = ptp->info;
>  	int err = -ENOMEM, i, n_pins = info->n_pins;
>  
> -	ptp->pin_dev_attr = kzalloc(n_pins * sizeof(*ptp->pin_dev_attr),
> +	ptp->pin_dev_attr = kcalloc(n_pins, sizeof(*ptp->pin_dev_attr),
>  				    GFP_KERNEL);
>  	if (!ptp->pin_dev_attr)
>  		goto no_dev_attr;
>  
> -	ptp->pin_attr = kzalloc((1 + n_pins) * sizeof(struct attribute *),
> -				GFP_KERNEL);
> +	ptp->pin_attr = kmalloc_array(1 + n_pins, sizeof(*ptp->pin_attr),
> +				      GFP_KERNEL);

I prefer kcalloc here as well, even if it isn't strictly necessary
according to the current usage of pin_attr.  That way, any future
changes to the pin handling code won't have to worry about
uninitialized memory.  After all, this is hardly a performance path.

>  	if (!ptp->pin_attr)
>  		goto no_pin_attr;
>  
> @@ -289,6 +289,9 @@ static int ptp_populate_pins(struct ptp_clock *ptp)
>  		ptp->pin_attr[i] = &da->attr;
>  	}
>  
> +	/* NULL terminator */
> +	ptp->pin_attr[n_pins] = NULL;

And drop this then, please.

Thanks,
Richard
