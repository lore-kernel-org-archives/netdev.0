From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Fix broken promiscuity reference counting
 issue
Date: Mon, 30 Sep 2013 22:12:22 -0700 (PDT)
Message-ID: <20130930.221222.2094260050523903528.davem@davemloft.net>
References: <1380298935-32140-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	wudxw@linux.vnet.ibm.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab3JAFFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:05:16 -0400
In-Reply-To: <1380298935-32140-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 27 Sep 2013 12:22:15 -0400

> Recently grabbed this report:
> https://bugzilla.redhat.com/show_bug.cgi?id=1005567
> 
> Of an issue in which the bonding driver, with an attached vlan encountered the
> following errors when bond0 was taken down and back up:
> 
> dummy1: promiscuity touches roof, set promiscuity failed. promiscuity feature of
> device might be broken.
> 
> The error occurs because, during __bond_release_one, if we release our last
> slave, we take on a random mac address and issue a NETDEV_CHANGEADDR
> notification.  With an attached vlan, the vlan may see that the vlan and bond
> mac address were in sync, but no longer are.  This triggers a call to dev_uc_add
> and dev_set_rx_mode, which enables IFF_PROMISC on the bond device.  Then, when
> we complete __bond_release_one, we use the current state of the bond flags to
> determine if we should decrement the promiscuity of the releasing slave.  But
> since the bond changed promiscuity state during the release operation, we
> incorrectly decrement the slave promisc count when it wasn't in promiscuous mode
> to begin with, causing the above error
> 
> Fix is pretty simple, just cache the bonding flags at the start of the function
> and use those when determining the need to set promiscuity.
> 
> This is also needed for the ALLMULTI flag
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Mark Wu <wudxw@linux.vnet.ibm.com>
> CC: "David S. Miller" <davem@davemloft.net>
> Reported-by: Mark Wu <wudxw@linux.vnet.ibm.com>

Applied.
