From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phy: Fix phy_device_free memory leak
Date: Thu, 28 Feb 2013 15:38:43 -0500 (EST)
Message-ID: <20130228.153843.113719126611463624.davem@davemloft.net>
References: <20130228110152.GA26262@bordel.klfree.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oss@malat.biz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab3B1Uio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 15:38:44 -0500
In-Reply-To: <20130228110152.GA26262@bordel.klfree.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Malat <oss@malat.biz>
Date: Thu, 28 Feb 2013 12:01:52 +0100

> 
> From: Petr Malat <oss@malat.biz>
> 
> Fix memory leak in phy_device_free() for the case when phy_device*
> returned by phy_device_create() is not registered in the system.
> 
> Bug description:
> phy_device_create() sets name of kobject using dev_set_name(), which 
> allocates memory using kvasprintf(), but this memory isn't freed if 
> the underlying device isn't registered properly, because kobject_cleanup()
> is not called in that case. This can happen (and actually is happening on 
> our machines) if phy_device_register(), called by mdiobus_scan(), fails. 
> 
> Patch description:
> Embedded struct device is initialized in phy_device_create() and it 
> counterpart phy_device_free() just drops one reference to the device,
> which leads to proper deinitialization including releasing the kobject 
> name memory.
> 
> Signed-off-by: Petr Malat <oss@malat.biz>

This looks great, applied, thanks.
