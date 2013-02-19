From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] bonding: Fix initialize after use for 3ad
 machine state spinlock
Date: Tue, 19 Feb 2013 00:52:47 -0500 (EST)
Message-ID: <20130219.005247.363934836692752429.davem@davemloft.net>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
	<1361210344-14907-2-git-send-email-nikolay@redhat.com>
	<21258.1361223190@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755610Ab3BSFwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:52:51 -0500
In-Reply-To: <21258.1361223190@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 18 Feb 2013 13:33:10 -0800

> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>>The 3ad machine state spinlock can be used before it is inititialized
>>while doing bond_enslave() (and the port is being initialized) since
>>port->slave is set before the lock is prepared, thus causing soft
>>lock-ups and a multitude of other nasty bugs.
> 
> 	Does this change cause the "uninitialized port" warnings in
> bond_3ad_state_machine_handler and bond_3ad_rx_indication to
> intermittently print during the enslavement process?  If so (and it
> looks to me like it will), I think the warnings should be removed, since
> after this change, port->slave being NULL isn't really an error
> condition that needs a warning to the log.
> 
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
 ...
>>-static inline void __initialize_port_locks(struct port *port)
>>+static inline void __initialize_port_locks(struct slave *port)
>> {
>> 	// make sure it isn't called twice
>>-	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
>>+	spin_lock_init(&(SLAVE_AD_INFO(port).state_machine_lock));
> 
> 	Change the name of the variable here, too, not just the type.
> This is confusing.

I made this adjustment and applied Nikolay's patch.
