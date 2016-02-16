From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bonding: don't use stale speed and duplex
 information
Date: Tue, 16 Feb 2016 15:14:48 -0500 (EST)
Message-ID: <20160216.151448.1415574551982584505.davem@davemloft.net>
References: <25869.1454962202@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, emil.s.tantilov@intel.com,
	zyjzyj2000@gmail.com, vfalico@gmail.com, dingtianhong@huawei.com,
	gospo@cumulusnetworks.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbcBPUOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:14:50 -0500
In-Reply-To: <25869.1454962202@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Mon, 08 Feb 2016 12:10:02 -0800

> 	There is presently a race condition between the bonding periodic
> link monitor and the updating of a slave's speed and duplex.  The former
> occurs on a periodic basis, and the latter in response to a driver's
> calling of netif_carrier_on.
> 
> 	It is possible for the periodic monitor to run between the
> driver call of netif_carrier_on and the receipt of the NETDEV_CHANGE
> event that causes bonding to update the slave's speed and duplex.  This
> manifests most notably as a report that a slave is up and "0 Mbps full
> duplex" after enslavement, but in principle could report an incorrect
> speed and duplex after any link up event if the device comes up with a
> different speed or duplex.  This affects the 802.3ad aggregator
> selection, as the speed and duplex are selection criteria.
> 
> 	This is fixed by updating the speed and duplex in the periodic
> monitor, prior to using that information.
> 
> 	This was done historically in bonding, but the call to
> bond_update_speed_duplex was removed in commit 876254ae2758 ("bonding:
> don't call update_speed_duplex() under spinlocks"), as it might sleep
> under lock.  Later, the locking was changed to only hold RTNL, and so
> after commit 876254ae2758 ("bonding: don't call update_speed_duplex()
> under spinlocks") this call is again safe.
> 
> Tested-by: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Cc: Veaceslav Falico <vfalico@gmail.com>
> Cc: dingtianhong <dingtianhong@huawei.com>
> Fixes: 876254ae2758 ("bonding: don't call update_speed_duplex() under spinlocks")
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

Applied, thanks Jay.
