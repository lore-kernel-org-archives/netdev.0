From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/5] net: Get skb hash over flow_keys
 structure
Date: Tue, 12 May 2015 10:30:46 -0400 (EDT)
Message-ID: <20150512.103046.1807865055959150687.davem@davemloft.net>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
	<1431401204-731380-2-git-send-email-tom@herbertland.com>
	<1431406606.566.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932632AbbELOau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:30:50 -0400
In-Reply-To: <1431406606.566.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 May 2015 21:56:46 -0700

> On Mon, 2015-05-11 at 20:26 -0700, Tom Herbert wrote:
 ...
> This (2) is not a multiple of 4, so some arches will have unaligned word
> accesses ?
 ...
>> -static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c, u32 keyval)
>> +static __always_inline u32 __flow_hash_words(u32 *words, u32 length, u32 keyval)
>>  {
>> -	return jhash_3words(a, b, c, keyval);
>> +	return jhash2(words, length, keyval);
>> +}
>> +
> 
> -> crash or very slow on MIPS.

Yeah you really can't do this.  You must only pass 4-byte aligned items
into the hash function.
