From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: port starting location not random
Date: Thu, 04 Oct 2012 17:12:11 -0400 (EDT)
Message-ID: <20121004.171211.1135905847490517665.davem@davemloft.net>
References: <20121004.170103.1493867833710136820.davem@davemloft.net>
	<b400428e-ffe4-42ee-b656-99b0314d64f4@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab2JDVMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 17:12:13 -0400
In-Reply-To: <b400428e-ffe4-42ee-b656-99b0314d64f4@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Thu, 04 Oct 2012 14:05:26 -0700 (PDT)

>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Thu, 4 Oct 2012 13:56:56 -0700
>> 
>> > -		first = (((u64)rand * remaining) >> 32) + low;
>> > +		first = rand % remaining + low;
>> 
>> I really don't get it, either a modulus via multiplcation
>> works or it doesn't.  We have this construct all over the
>> place.
>> 
>> 
> 
> Try out of kernel:
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <stdint.h>
> 
> int main(int ac, char **av) {
> 	int low, high, remaining;
> 	unsigned int rand;
> 	unsigned short first;
> 
> 	low = atoi(av[1]);
> 	high = atoi(av[2]);
> 	remaining = (high - low) + 1;
> 	rand = atoi(av[3]);
> 
> 	first = (((uint64_t)rand * remaining) >> 32) + low;
> 
> 	printf("%d %d %u => %u\n", low, high, rand, first);
> 	return 0;
> }
> 
> $ port-test 32768 61000 $RANDOM
> 32768 61000 7027 => 32768

It just shows that we need to shift "remaining" up into the top N
bits instead of the bottom N bits.
