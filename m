From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 3/7] TAP: Tap character device creation/destroy API
Date: Wed, 18 Jan 2017 16:26:47 -0500 (EST)
Message-ID: <20170118.162647.1034141344569503382.davem@davemloft.net>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
        <1484697786-50323-4-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41284 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdARV0s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 16:26:48 -0500
In-Reply-To: <1484697786-50323-4-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Tue, 17 Jan 2017 16:03:02 -0800

> +int tap_create_cdev(struct cdev *tap_cdev,
> +		    dev_t *tap_major, const char *device_name)
> +{
> +	int err;
> +
> +	err = alloc_chrdev_region(tap_major, 0, TAP_NUM_DEVS, device_name);
> +
> +	if (err)
> +		goto out1;

No need to have an empty line between the alloc_chrdev_region() call
and the "if (err)" test.

> diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h
> index d887aaa..a2dfd90 100644
> --- a/include/linux/if_tap.h
> +++ b/include/linux/if_tap.h
> @@ -10,7 +10,7 @@ struct file;
>  struct socket;
>  static inline struct socket *tap_get_socket(struct file *f)
>  {
> -        return ERR_PTR(-EINVAL);
> +	return ERR_PTR(-EINVAL);
>  }

Instead of having to fix up the indentation here, get it right in the first place
in patch #2.
