From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] bonding: fix bond_release_all
 inconsistencies
Date: Tue, 19 Feb 2013 00:53:09 -0500 (EST)
Message-ID: <20130219.005309.422120147438064243.davem@davemloft.net>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
	<1361232582-19420-1-git-send-email-nikolay@redhat.com>
	<29485.1361243521@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754598Ab3BSFxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:53:10 -0500
In-Reply-To: <29485.1361243521@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 18 Feb 2013 19:12:01 -0800

> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>>This patch fixes the following inconsistencies in bond_release_all:
>>- IFF_BONDING flag is not stripped from slaves
>>- MTU is not restored
>>- no netdev notifiers are sent
>>Instead of trying to keep bond_release and bond_release_all in sync
>>I think we can re-use bond_release as the environment for calling it
>>is correct (RTNL is held). I have been running tests for the past
>>week and they came out successful. The only way for bond_release to fail
>>is for the slave to be attached in a different bond or to not be a slave
>>but that cannot happen as RTNL is held and no slave manipulations can be
>>achieved.
>>
>>V2: As suggested bond_release is renamed to __bond_release_one with a
>>new parameter "all" introduced so to avoid calling unnecessary code while
>>destroying a bond, and a wrapper for it called bond_release is created
>>because of ndo_del_link. bond_release_all() is removed.
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
