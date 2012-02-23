From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] mlx4_en: moderate frequency of TX
 completions
Date: Thu, 23 Feb 2012 16:46:42 -0500 (EST)
Message-ID: <20120223.164642.1510847570351068406.davem@davemloft.net>
References: <4F464063.1010001@mellanox.co.il>
	<20120223.144437.32389814881687535.davem@davemloft.net>
	<1330031636.2511.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288Ab2BWVqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 16:46:52 -0500
In-Reply-To: <1330031636.2511.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 23 Feb 2012 21:13:56 +0000

> On Thu, 2012-02-23 at 14:44 -0500, David Miller wrote:
>> From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
>> Date: Thu, 23 Feb 2012 15:34:27 +0200
>> 
>> > No need to ask for completion for every packet being sent.
>> > So the method is to ask for a completion every 16 packets,
>> > or when the queue is about to be full.
>> > 
>> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
>> 
>> You absolutely cannot do this, you must signal completion and free up
>> TX queue packets in a finite amount of time.
> 
> Really, sfc has been doing this forever.

You have to stop, because otherwise sockets can hang since those
packets can hold a reference to the socket so they must be
released in a finite amount of time regardless of network
traffic.
