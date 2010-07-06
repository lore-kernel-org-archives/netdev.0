From: David Miller <davem@davemloft.net>
Subject: Re: bridge br_multicast: BUG: unable to handle kernel NULL pointer
 dereference
Date: Mon, 05 Jul 2010 20:07:24 -0700 (PDT)
Message-ID: <20100705.200724.45878250.davem@davemloft.net>
References: <1278356737.2163.45.camel@mendozza.osrc.amd.com>
	<20100706004835.GA11611@gondor.apana.org.au>
	<20100706005008.GA11699@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: frank.arnold@amd.com, shemminger@vyatta.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752355Ab0GFDHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 23:07:12 -0400
In-Reply-To: <20100706005008.GA11699@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 6 Jul 2010 08:50:08 +0800

> On Tue, Jul 06, 2010 at 08:48:35AM +0800, Herbert Xu wrote:
>> 
>> bridge: Restore NULL check in br_mdb_ip_get
> 
> Resend with proper attribution.
> 
> bridge: Restore NULL check in br_mdb_ip_get
> 
> Somewhere along the line the NULL check in br_mdb_ip_get went
> AWOL, causing crashes when we receive an IGMP packet with no
> multicast table allocated.

It got removed by:

--------------------
commit 8ef2a9a59854994bace13b5c4f7edc2c8d4d124e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Apr 18 12:42:07 2010 +0900

    bridge br_multicast: Make functions less ipv4 dependent.
    
    Introduce struct br_ip{} to store ip address and protocol
    and make functions more generic so that we can support
    both IPv4 and IPv6 with less pain.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
--------------------

> This patch restores it and ensures all br_mdb_*_get functions
> use it.
> 
> Reported-by: Frank Arnold <frank.arnold@amd.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
