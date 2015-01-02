From: David Miller <davem@davemloft.net>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Fri, 02 Jan 2015 16:13:55 -0500 (EST)
Message-ID: <20150102.161355.1471650729858130736.davem@davemloft.net>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	<20141201102522.GA16579@gondor.apana.org.au>
	<20141231133923.GA30248@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.jarosch@intra2net.com, netdev@vger.kernel.org,
	edumazet@google.com, steffen.klassert@secunet.com,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbbABVN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:13:58 -0500
In-Reply-To: <20141231133923.GA30248@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 1 Jan 2015 00:39:23 +1100

> Thomas Jarosch reported IPsec TCP stalls when a PMTU event occurs.
> 
> In fact the problem was completely unrelated to IPsec.  The bug is
> also reproducible if you just disable TSO/GSO.
> 
> The problem is that when the MSS goes down, existing queued packet
> on the TX queue that have not been transmitted yet all look like
> TSO packets and get treated as such.
> 
> This then triggers a bug where tcp_mss_split_point tells us to
> generate a zero-sized packet on the TX queue.  Once that happens
> we're screwed because the zero-sized packet can never be removed
> by ACKs.
> 
> Fixes: 1485348d242 ("tcp: Apply device TSO segment limit earlier")
> Reported-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
