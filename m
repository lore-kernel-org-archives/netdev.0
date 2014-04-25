From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Fri, 25 Apr 2014 13:33:03 -0400 (EDT)
Message-ID: <20140425.133303.375967970436600096.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6FF01A@AcuExch.aculab.com>
	<20140425.125155.861435686727308330.davem@davemloft.net>
	<20140425171909.GB7050@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, lorenzo@google.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaDYRdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 13:33:05 -0400
In-Reply-To: <20140425171909.GB7050@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 25 Apr 2014 19:19:09 +0200

> Maybe we can put all those hlimit, tclass, dontfrag vars into a struct
> and just pass one pointer.

It's still an unnecessary memory dereference.

The compiler can potentially optimize the accesses to those variables
into a local register with the existing code, with this consolidation
it no longer can.
