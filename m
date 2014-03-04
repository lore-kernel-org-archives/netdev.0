From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unix socket code abuses csum_partial
Date: Tue, 04 Mar 2014 16:23:29 -0500 (EST)
Message-ID: <20140304.162329.504474868666088316.davem@davemloft.net>
References: <20140304210104.42ef3dd8@kryten>
	<20140304.134141.1732220919806520941.davem@davemloft.net>
	<1393959053.26794.126.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, edumazet@google.com, gustavold@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757001AbaCDVXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:23:31 -0500
In-Reply-To: <1393959053.26794.126.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Mar 2014 10:50:53 -0800

> On Tue, 2014-03-04 at 13:41 -0500, David Miller wrote:
> 
>> Alternatively you could just make unix_hash_fold() use csum_fold(),
>> right?
>> 
>> static inline unsigned int unix_hash_fold(__wsum n)
>> {
>> 	unsigned int hash = (__force unsigned int) csum_fold(n);
>> 
>> 	hash ^= hash>>8;
>> 	return hash&(UNIX_HASH_SIZE-1);
>> }
> 
> Or simply use full_name_hash()

I would prefer not, because this would be a performance regression
on platforms other than x86 and ARM, because only they implement
the optimized load_unaligned_zeropad().

Other architectures would end up with a byte-by-byte hash computation.
