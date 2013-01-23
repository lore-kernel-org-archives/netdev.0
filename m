From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 22 Jan 2013 23:17:54 -0500 (EST)
Message-ID: <20130122.231754.2210645494690728329.davem@davemloft.net>
References: <FD9AD8C5375B924CABC56D982DB3A802079D32D1@EXMB1.micrel.com>
	<20130122.205132.2281610193783011537.davem@davemloft.net>
	<1358913454.2107.16.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org,
	Ping.Doong@Micrel.Com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab3AWER4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 23:17:56 -0500
In-Reply-To: <1358913454.2107.16.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 22 Jan 2013 19:57:34 -0800

> On Tue, 2013-01-22 at 20:51 -0500, David Miller wrote:
>> BTW it's inappropriate to log an SKB allocation failure as an error in
>> the kernel logs like this.  This can be completely normal on a heavily
>> loaded system.  People can look at the device statistics to learn about
>> this event, or use a more sophisticated tool like the drop monitor.
> 
> There are many of these still around, though
> hardly any in modern drivers.

Right.

> I get this file list in drivers/net/ of
> alloc_skb failures followed by printks:
> 
> Almost all of these are pretty old and are
> probably best described as "don't bother".

Be also careful to not match the ones that are done to
do something like the initial RX ring filling during
device open.

If such an allocation failure causes device open to fail,
that's a legitimate situation in which to log.
