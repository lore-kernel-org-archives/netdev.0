From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Driver for IBM System i/p VNIC protocol
Date: Sat, 05 Dec 2015 22:25:51 -0500 (EST)
Message-ID: <20151205.222551.512793392902323297.davem@davemloft.net>
References: <1449251386-13476-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	nfont@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	nguyendo@us.ibm.com, jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbbLFDZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 22:25:54 -0500
In-Reply-To: <1449251386-13476-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Fri,  4 Dec 2015 11:49:46 -0600

> +static int ibmvnic_buffs_per_pool = IBMVNIC_BUFFS_PER_POOL;
> +module_param(ibmvnic_buffs_per_pool, int, S_IRUGO);
> +MODULE_PARM_DESC(ibmvnic_buffs_per_pool,
> +		 "IBMVNIC number of buffers per rx pool");

Please do not use module parameters for settings that effect
the basic operation of the driver.

Instead use facilities that are generic and provide the same
user interface for all networking drivers, such as ethtool.

Otherwise users would need to learn a different way to configure the
same thing on different devices, which is not acceptable.
