From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: lmc: Switch to using managed resources
Date: Tue, 01 Mar 2016 17:21:53 -0500 (EST)
Message-ID: <20160301.172153.99852560992201587.davem@davemloft.net>
References: <20160227170416.GA1339@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbcCAWVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:21:55 -0500
In-Reply-To: <20160227170416.GA1339@amitoj-Inspiron-3542>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Sat, 27 Feb 2016 22:34:16 +0530

> @@ -835,23 +835,20 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	err = pci_request_regions(pdev, "lmc");
>  	if (err) {
>  		printk(KERN_ERR "lmc: pci_request_region failed\n");
> -		goto err_req_io;
> +		return err;
>  	}
>  
>  	/*
>  	 * Allocate our own device structure
>  	 */
> -	sc = kzalloc(sizeof(lmc_softc_t), GFP_KERNEL);
> -	if (!sc) {
> -		err = -ENOMEM;
> -		goto err_kzalloc;

You can't get rid of the error paths from here on out, because you still need to
release the PCI regions obtained from pci_request_regions() above.

To be quite honest, unless you are fixing real bugs, managed resource
converstions are more likely to add bugs than do anything truly
useful.

I strongly consider you just drop this change.
