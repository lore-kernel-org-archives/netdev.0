From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Mon, 02 Mar 2009 02:56:19 -0500
Message-ID: <1235980579.23967.2.camel@localhost.localdomain>
References: <20090301.174433.258919971.davem@davemloft.net>
	 <1235963807.27973.1.camel@localhost.localdomain>
	 <20090301.201123.112634333.davem@davemloft.net>
	 <20090301.202929.81587113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:58644 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbZCBH4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 02:56:23 -0500
In-Reply-To: <20090301.202929.81587113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-03-01 at 20:29 -0800, David Miller wrote:
> I cared enough to fix this, maybe one of you will care enough
> to test it.

Like I said, I will be happy to test as soon as I can dig the hardware
out. In any event, this is broken.

>  static int
>  typhoon_request_firmware(struct typhoon *tp)
> @@ -1367,12 +1368,22 @@ typhoon_request_firmware(struct typhoon *tp)
>  	    memcmp(typhoon_fw->data, "TYPHOON", 8)) {
>  		printk(KERN_ERR "%s: Invalid firmware image\n",
>  		       tp->name);
> -		release_firmware(typhoon_fw);
> -		typhoon_fw = NULL;
> -		return -EINVAL;
> +		err = -EINVAL;
> +		goto out_err;
> +	}
> +
> +	typhoon_fw_image = kmalloc(typhoon_fw->size, GFP_KERNEL);
> +	if (!typhoon_fw_image) {
> +		err = -ENOMEM;
> +		goto out_err;
>  	}

You never copied the image into the kmalloc'd memory, so you upload
garbage.

Fix that and I think it will be OK.

