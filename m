From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Fri, 14 Dec 2007 22:40:49 +0100
Message-ID: <4762F861.6050804@gmail.com>
References: <4762646B.30207@cosmosbay.com> <4762EEB2.1080608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4762EEB2.1080608@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote, On 12/14/2007 09:59 PM:

> Eric Dumazet wrote, On 12/14/2007 12:09 PM:
> ...
> 
>> +	/*
>> +	 * Instead of returning hash % ht->cfg.size (implying a divide)
>> +	 * we return the high 32 bits of the (hash * ht->cfg.size) that will
>> +	 * give results between [0 and cfg.size-1] and same hash distribution,
>> +	 * but using a multiply, less expensive than a divide
>> +	 */
>> +	return ((u64)hash * ht->cfg.size) >> 32;
> 
> Are we sure of the same hash distribution? Probably I miss something,
> but: if this 'hash' is well distributed on 32 bits, and ht->cfg.size
> is smaller than 32 bits, e.g. 256 (8 bits), then this multiplication
> moves to the higher 32 of u64 only max. 8 bits of the most significant
> byte, and the other three bytes are never used, while division is
> always affected by all four bytes...


OOPS! So, I've missed this division here is also affected by only one
byte, but from the other side - so, almost the same... It seems this
could have been replaced with masking from the beginning...

Sorry,
Jarek P.
