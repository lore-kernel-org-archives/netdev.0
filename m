From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: small bug on rxhash calculation
Date: Sat, 08 Sep 2012 18:43:27 -0400 (EDT)
Message-ID: <20120908.184327.1052019215545004538.davem@davemloft.net>
References: <20120907.125748.25526531079163699.davem@davemloft.net>
	<1347061251-2019-1-git-send-email-chema@google.com>
	<1347092320.1234.335.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chema@google.com, edumazet@google.com, netdev@vger.kernel.org,
	chema@berkeley.edu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375Ab2IHWn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 18:43:29 -0400
In-Reply-To: <1347092320.1234.335.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 08 Sep 2012 10:18:40 +0200

> On Fri, 2012-09-07 at 16:40 -0700, Chema Gonzalez wrote:
>> In the current rxhash calculation function, while the
>> sorting of the ports/addrs is coherent (you get the
>> same rxhash for packets sharing the same 4-tuple, in
>> both directions), ports and addrs are sorted
>> independently. This implies packets from a connection
>> between the same addresses but crossed ports hash to
>> the same rxhash.
>> 
>> For example, traffic between A=S:l and B=L:s is hashed
>> (in both directions) from {L, S, {s, l}}. The same
>> rxhash is obtained for packets between C=S:s and D=L:l.
>> 
>> This patch ensures that you either swap both addrs and ports,
>> or you swap none. Traffic between A and B, and traffic
>> between C and D, get their rxhash from different sources
>> ({L, S, {l, s}} for A<->B, and {L, S, {s, l}} for C<->D)
>> 
>> The patch is co-written with Eric Dumazet <edumazet@google.com>
>> 
>> Signed-off-by: Chema Gonzalez <chema@google.com>
>> ---
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
