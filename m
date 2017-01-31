From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 5/7] tap: Extending tap device create/destroy APIs
Date: Tue, 31 Jan 2017 12:51:12 -0500 (EST)
Message-ID: <20170131.125112.287960842388784953.davem@davemloft.net>
References: <1485803522-16564-1-git-send-email-sainath.grandhi@intel.com>
        <1485803522-16564-6-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdAaRvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 12:51:20 -0500
In-Reply-To: <1485803522-16564-6-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Mon, 30 Jan 2017 11:12:00 -0800

> +	list_for_each_entry_safe(tap_major, tmp, &major_list, next) {
> +		if (tap_major->major == major) {
> +			return tap_major;
> +		}
> +	}

Single line basic blocks, such as this 'if' statement, should not be
surrounded by curly braces.

Also I see not mutual exclusion being implemented to protect this
list.  If there is, it is not obvious, so it should be documented with
a comment explaining what protects the list.

> @@ -1175,14 +1228,7 @@ int tap_create_cdev(struct cdev *tap_cdev,
>  	if (err)
>  		goto out2;
>  
> -	macvtap_major.major = MAJOR(*tap_major);
> -
> -	idr_init(&macvtap_major.minor_idr);
> -	mutex_init(&macvtap_major.minor_lock);
> -
> -	macvtap_major.device_name = device_name;
> -
> -	return err;
> +	return tap_list_add(*tap_major, device_name);
>  
>  out2:
>  	unregister_chrdev_region(*tap_major, TAP_NUM_DEVS);

If tap_list_add() fails, you will leave the chrdev region registered.
