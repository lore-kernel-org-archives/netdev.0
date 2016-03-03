From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Propagate MAC address changes to VLANs
Date: Thu, 03 Mar 2016 16:12:40 -0500 (EST)
Message-ID: <20160303.161240.631812391738601311.davem@davemloft.net>
References: <56D42C63.1070602@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573AbcCCVMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:12:44 -0500
In-Reply-To: <56D42C63.1070602@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Mon, 29 Feb 2016 11:32:51 +0000

>  
> -	/* vlan address was equal to the old address and is different from
> +	/* vlan address was equal to the old address so now also inherit
>  	 * the new address */
> -	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
> -	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
> -		dev_uc_add(dev, vlandev->dev_addr);
> +	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr))
> +		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
>  

This dev_uc_add() call removal cannot be correct, if the device is up
we must programe it into the hardware unicast filters and if also
potentially put it into promiscuous mode via __dev_set_rx_mode().

Also your subject line isn't formatted properly, it should be:

	[PATCH net] vlan: Propagate MAC address changes properly.
