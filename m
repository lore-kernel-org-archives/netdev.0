From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix panic on non-ARPHRD_ETHER enslave
 failure
Date: Sat, 07 Nov 2015 13:19:26 -0500 (EST)
Message-ID: <20151107.131926.775188308059174697.davem@davemloft.net>
References: <9700.1446859403@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbbKGST1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 13:19:27 -0500
In-Reply-To: <9700.1446859403@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Fri, 06 Nov 2015 17:23:23 -0800

> 
> 	Since commit 7d5cd2ce529b, when bond_enslave fails on devices that
> are not ARPHRD_ETHER, if needed, it resets the bonding device back to
> ARPHRD_ETHER by calling ether_setup.
> 
> 	Unfortunately, ether_setup clobbers dev->flags, clearing IFF_UP
> if the bond device is up, leaving it in a quasi-down state without
> having actually gone through dev_close.  For bonding, if any periodic
> work queue items are active (miimon, arp_interval, etc), those will
> remain running, as they are stopped by bond_close.  At this point, if
> the bonding module is unloaded or the bond is deleted, the system will
> panic when the work function is called.
> 
> 	This panic is resolved by calling dev_close on the bond itself
> prior to calling ether_setup.
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> Fixes: 7d5cd2ce5292 ("bonding: correctly handle bonding type change on enslave failure")

Applied and queued up for -stable, thanks.
