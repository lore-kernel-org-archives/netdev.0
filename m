From: David Miller <davem@davemloft.net>
Subject: Re: arp_hash
Date: Sun, 22 Mar 2015 18:58:50 -0400 (EDT)
Message-ID: <20150322.185850.927485035002538859.davem@davemloft.net>
References: <20150322114204.GA5010@gondor.apana.org.au>
	<1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150322215612.GA8274@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	roland@purestorage.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbbCVW6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 18:58:52 -0400
In-Reply-To: <20150322215612.GA8274@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 23 Mar 2015 08:56:12 +1100

> On Sun, Mar 22, 2015 at 05:56:21AM -0700, Eric Dumazet wrote:
>> On Sun, 2015-03-22 at 22:42 +1100, Herbert Xu wrote:
>> > 
>> > While googling I found the 2011 discussion on changing the arp_hash
>> > function.  I must say that I'm not really impressed by the new
>> > function that replaced jhash :)
>> > 
>> > 	u32 key = *(const u32 *)pkey;
>> > 	u32 val = key ^ hash32_ptr(dev);
>> > 
>> > 	return val * hash_rnd[0];
> 
> In fact this function is worse than I thought.  Because the IP
> address is stored in big-endian, the low bits correspond to the
> first octet.  So in any network smaller than a /8 everything
> hashes the same value.

I won't argue that there might be some bugs here, and there is some
lost entropy, and that we should fix them.

But I do not agree with the idea that it is in any way possible to
stop someone with root access on the physical network from crudding up
our ARP hash tables.
