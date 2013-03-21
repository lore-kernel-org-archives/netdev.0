From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 12:31:22 -0400 (EDT)
Message-ID: <20130321.123122.1792402145612438586.davem@davemloft.net>
References: <1363841553.3333.47.camel@edumazet-glaptop>
	<20130321.114616.279859400813363663.davem@davemloft.net>
	<1363882825.2736.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dmitry@broadcom.com, eilong@broadcom.com, pshelar@nicira.com,
	hkchu@google.com, maze@google.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414Ab3CUQbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 12:31:24 -0400
In-Reply-To: <1363882825.2736.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 21 Mar 2013 16:20:25 +0000

> On Thu, 2013-03-21 at 11:46 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 20 Mar 2013 21:52:33 -0700
>> 
>> > GRE TSO support doesn't increment the ID in the inner IP header.
>> 
>> Is this a fundamental limitation of doing TSO over GRO or
>> were the Broadcom folks just being lazy with their firmware
>> implementation?
>> 
>> I really don't want to apply this patch, because ipv4 frames
>> even with DF set should have an incrementing ID field, in
>> order to accomodate various header compression schemes.
>> 
>> We go out of our way to do this for normal unencapsulated TCP stream
>> packets, rather than set the ID field to zero (which we did for some
>> time until the compression issue was pointed out to us).
> 
> Besides which, GRO has been reliably reversible until now.  (gso_size is
> available through packet sockets, even if tcpdump doesn't appear to use
> it yet.)  Ignoring IPv4 IDs will break that guarantee.

Right, even ignoring the header compression issues, our segmentation
offloads must be perfectly reversible.
