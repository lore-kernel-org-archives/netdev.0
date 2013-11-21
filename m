From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix ehea warning when built in
Date: Thu, 21 Nov 2013 13:07:54 -0500 (EST)
Message-ID: <20131121.130754.2206370935570985768.davem@davemloft.net>
References: <11586.1385008609@ale.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffm@suse.com, ohering@suse.com, jslaby@suse.cz,
	netdev@vger.kernel.org, cascardo@linux.vnet.ibm.com
To: mikey@neuling.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3KUSH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:07:56 -0500
In-Reply-To: <11586.1385008609@ale.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Neuling <mikey@neuling.org>
Date: Thu, 21 Nov 2013 15:36:49 +1100

> In:
>   commit 7a3a62128388a6af771e99df8628ddee2e8be7ca
>   Author: Olaf Hering <ohering@suse.com>
>   drivers/net/ethernet/ibm/ehea/ehea_main.c: add alias entry for portN properties
> We added ehea_module_device_table.  Unfortunately we only use this when
> building as a module so we get the following warning when built in, like
> in pseries_defconfig:
> 
>   drivers/net/ethernet/ibm/ehea/ehea_main.c:105:1: warning: 'ehea_module_device_table' defined but not used [-Wunused-variable]
> 
> This wraps ehea_module_device_table with #if MODULE.
> 
> Signed-off-by: Michael Neuling <mikey@neuling.org>

I think putting an ugly MODULE ifdef into every driver that does something
like this is not going to cut it.

Rather, the MODULE_DEVICE_TABLE() definition when !MODULE should do something
reasonable, like make a void reference to the symbole.

I'm not applying this, the fix belongs in a generic place.

Thanks.
