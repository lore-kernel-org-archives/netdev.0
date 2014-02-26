From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix a div error caused by the slave
 release path
Date: Wed, 26 Feb 2014 17:23:44 -0500 (EST)
Message-ID: <20140226.172344.2063576636598224310.davem@davemloft.net>
References: <1393420830-20932-1-git-send-email-nikolay@redhat.com>
	<20140226132854.GA24011@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbaBZWXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:23:46 -0500
In-Reply-To: <20140226132854.GA24011@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Wed, 26 Feb 2014 14:28:54 +0100

> On Wed, Feb 26, 2014 at 02:20:30PM +0100, Nikolay Aleksandrov wrote:
>>There's a bug in the slave release function which leads the transmit
>>functions which use the bond->slave_cnt to a div by 0 because we might
>>just have released our last slave and made slave_cnt == 0 but at the
>>same
>>time we may have a transmitter after the check for an empty list which
>>will
>>fetch it and use it in the slave id calculation.
>>Fix it by moving the slave_cnt after synchronize_rcu so if this was
>>our
>>last slave any new transmitters will see an empty slave list which is
>>checked after rcu lock but before calling the mode transmit functions
>>which rely on bond->slave_cnt.
>>
>>Fixes: 278b208375 ("bonding: initial RCU conversion")
>>
>>CC: Veaceslav Falico <vfalico@redhat.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>CC: Jay Vosburgh <fubar@us.ibm.com>
>>CC: David S. Miller <davem@davemloft.net>
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Acked-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
