From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/38] net: atm: add missing put_device call
Date: Fri, 27 Dec 2013 12:40:22 -0500 (EST)
Message-ID: <20131227.124022.439150072696415687.davem@davemloft.net>
References: <1387465429-3568-2-git-send-email-levex@linux.com>
	<1387465429-3568-20-git-send-email-levex@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: levex@linux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387465429-3568-20-git-send-email-levex@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Levente Kurusa <levex@linux.com>
Date: Thu, 19 Dec 2013 16:03:30 +0100

> This is required so that we give up the last reference to the device.
> 
> Signed-off-by: Levente Kurusa <levex@linux.com>
 ...
> @@ -154,8 +154,10 @@ int atm_register_sysfs(struct atm_dev *adev, struct device *parent)
>  
>  	dev_set_name(cdev, "%s%d", adev->type, adev->number);
>  	err = device_register(cdev);
> -	if (err < 0)
> +	if (err < 0) {
> +		put_device(cdev);
>  		return err;
> +	}

This doesn't make any sense.

Nothing has a reference to 'cdev'.  Yes, 'adev' has a reference,
acquired by the caller of this function, but that's not what we're
working with here.
