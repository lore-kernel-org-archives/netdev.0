From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] ethernet: realtek: use
 module_pci_driver
Date: Tue, 22 Jul 2014 00:28:50 -0700 (PDT)
Message-ID: <20140722.002850.1113335731441581168.davem@davemloft.net>
References: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com>
	<1406013622-27869-2-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbaGVH2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 03:28:55 -0400
In-Reply-To: <1406013622-27869-2-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: varkabhadram@gmail.com
Date: Tue, 22 Jul 2014 12:50:21 +0530

> @@ -1887,11 +1887,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
>  	resource_size_t pciaddr;
>  	unsigned int addr_len, i, pci_using_dac;
>  
> -#ifndef MODULE
> -	static int version_printed;
> -	if (version_printed++ == 0)
> -		pr_info("%s", version);
> -#endif
> +	pr_info("%s", version);

Now you're changing behavior undesirably, it will now print the
version string into the logs for every instance of the device which is
discovered.

Seriously, the driver is worse off after these "cleanups".
