From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix enslaving in alb mode when link down
Date: Wed, 18 Jan 2012 21:00:30 -0500 (EST)
Message-ID: <20120118.210030.1601111277639073289.davem@davemloft.net>
References: <20120118222454.GA11966@midget.suse.cz>
	<23580.1326937521@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756547Ab2ASCBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 21:01:51 -0500
In-Reply-To: <23580.1326937521@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 18 Jan 2012 17:45:21 -0800

> Jiri Bohac <jbohac@suse.cz> wrote:
> 
>>bond_alb_init_slave() is called from bond_enslave() and sets the slave's MAC
>>address. This is done differently for TLB and ALB modes.
>>bond->alb_info.rlb_enabled is used to discriminate between the two modes but
>>this flag may be uninitialized if the slave is being enslaved prior to calling
>>bond_open() -> bond_alb_initialize() on the master.
>>
>>It turns out all the callers of alb_set_slave_mac_addr() pass
>>bond->alb_info.rlb_enabled as the hw parameter.
>>
>>This patch cleans up the unnecessary parameter of alb_set_slave_mac_addr() and
>>makes the function decide based on the bonding mode instead, which fixes the
>>above problem.
>>
>>Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 
> 	Looks reasonable.
> 
> 	-J
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied and queued up for -stable, thanks everyone.
