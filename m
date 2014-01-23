From: David Miller <davem@davemloft.net>
Subject: Re: Linux kernel patch: elide fib_validate_source() completely
 when possible - bad side effect?
Date: Wed, 22 Jan 2014 18:53:05 -0800 (PST)
Message-ID: <20140122.185305.1125981867482223830.davem@davemloft.net>
References: <52DCF1440200005D000477FD@gwia2.atlnz.lc>
	<alpine.LFD.2.11.1401222222010.1855@ja.home.ssi.bg>
	<20140123020224.GG7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, gregory.hoggarth@alliedtelesis.co.nz,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbaAWCxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 21:53:09 -0500
In-Reply-To: <20140123020224.GG7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 23 Jan 2014 03:02:24 +0100

> On Wed, Jan 22, 2014 at 11:04:52PM +0200, Julian Anastasov wrote:
>> 	I don't remember someone mentioning about such
>> side-effect, I guess it is overlooked. IMHO, it is not a good
>> reason to restore the old behavior. Lets see other opinions.
> 
> A routing lookup to check for broadcast is much too expansive, I agree. But
> can't we just check skb->pkt_type == PACKET_BROADCAST?

We can't universally know what a broadcast is, because the prefix of
every network is a local piece of information.

We might not have the route necessary to know the source address is
a broadcast if the packet came through more than 1 hop already.
