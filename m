From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bonding: move bond-specific init after
 enslave happens
Date: Tue, 22 Oct 2013 19:22:45 -0400 (EDT)
Message-ID: <20131022.192245.1464483820935228355.davem@davemloft.net>
References: <1382348910-32724-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, dingtianhong@huawei.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3JVXWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 19:22:47 -0400
In-Reply-To: <1382348910-32724-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 21 Oct 2013 11:48:30 +0200

> As Jiri noted, currently we first do all bonding-specific initialization
> (specifically - bond_select_active_slave(bond)) before we actually attach
> the slave (so that it becomes visible through bond_for_each_slave() and
> friends). This might result in bond_select_active_slave() not seeing the
> first/new slave and, thus, not actually selecting an active slave.
> 
> Fix this by moving all the bond-related init part after we've actually
> completely initialized and linked (via bond_master_upper_dev_link()) the
> new slave.
> 
> Also, remove the bond_(de/a)ttach_slave(), it's useless to have functions
> to ++/-- one int.
> 
> After this we have all the initialization of the new slave *before*
> linking, and all the stuff that needs to be done on bonding *after* it. It
> has also a bonus effect - we can remove the locking on the new slave init
> completely, and only use it for bond_select_active_slave().
> 
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
