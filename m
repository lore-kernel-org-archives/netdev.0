From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 1/1] [PATCH BUG_FIX] ipv6: fix refcnt problem related
	to POSTDAD state
Date: Mon, 25 Oct 2010 16:01:32 -0700
Message-ID: <20101025230132.GA5474@gondor.apana.org.au>
References: <20101025090642.958260964@linux.vnet.ibm.com> <20101025090716.315678235@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	vosburgh@de.ibm.com, "David S. Miller" <davem@davemloft.net>
To: Ursula Braun <ursula.braun@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43320 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab0JYXBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 19:01:38 -0400
Content-Disposition: inline
In-Reply-To: <20101025090716.315678235@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 11:06:43AM +0200, Ursula Braun wrote:
> Subject: [patch 1/1] [PATCH BUG_FIX] ipv6: fix refcnt problem related to POSTDAD state
> 
> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> After running this bonding setup script
>     modprobe bonding miimon=100 mode=0 max_bonds=1
>     ifconfig bond0 10.1.1.1/16
>     ifenslave bond0 eth1
>     ifenslave bond0 eth3
> on s390 with qeth-driven slaves, modprobe -r fails with this message
>     unregister_netdevice: waiting for bond0 to become free. Usage count = 1
> due to twice detection of duplicate address.
> Problem is caused by a missing decrease of ifp->refcnt in addrconf_dad_failure.
> An extra call of in6_ifa_put(ifp) solves it.
> Problem has been introduced with commit f2344a131bccdbfc5338e17fa71a807dee7944fa.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Cc: David S. Miller <davem@davemloft.net>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for catching this!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
