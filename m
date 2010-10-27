From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] [PATCH BUG_FIX] ipv6: fix refcnt problem related
 to POSTDAD state
Date: Wed, 27 Oct 2010 11:10:14 -0700 (PDT)
Message-ID: <20101027.111014.260072078.davem@davemloft.net>
References: <20101025090642.958260964@linux.vnet.ibm.com>
	<20101025090716.315678235@linux.vnet.ibm.com>
	<20101025230132.GA5474@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ursula.braun@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, vosburgh@de.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43611
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754114Ab0J0SJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:09:51 -0400
In-Reply-To: <20101025230132.GA5474@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 25 Oct 2010 16:01:32 -0700

> On Mon, Oct 25, 2010 at 11:06:43AM +0200, Ursula Braun wrote:
>> Subject: [patch 1/1] [PATCH BUG_FIX] ipv6: fix refcnt problem related to POSTDAD state
>> 
>> From: Ursula Braun <ursula.braun@de.ibm.com>
>> 
>> After running this bonding setup script
>>     modprobe bonding miimon=100 mode=0 max_bonds=1
>>     ifconfig bond0 10.1.1.1/16
>>     ifenslave bond0 eth1
>>     ifenslave bond0 eth3
>> on s390 with qeth-driven slaves, modprobe -r fails with this message
>>     unregister_netdevice: waiting for bond0 to become free. Usage count = 1
>> due to twice detection of duplicate address.
>> Problem is caused by a missing decrease of ifp->refcnt in addrconf_dad_failure.
>> An extra call of in6_ifa_put(ifp) solves it.
>> Problem has been introduced with commit f2344a131bccdbfc5338e17fa71a807dee7944fa.
>> 
>> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
>> Cc: David S. Miller <davem@davemloft.net>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Thanks for catching this!

Applied, thanks everyone.
