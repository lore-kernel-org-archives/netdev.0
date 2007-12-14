From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Fri, 14 Dec 2007 22:37:15 +0100
Message-ID: <4762F78B.80302@cosmosbay.com>
References: <4762646B.30207@cosmosbay.com> <4762EEB2.1080608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4762EEB2.1080608@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski a =E9crit :
> Eric Dumazet wrote, On 12/14/2007 12:09 PM:
> ...
>=20
>> +	/*
>> +	 * Instead of returning hash % ht->cfg.size (implying a divide)
>> +	 * we return the high 32 bits of the (hash * ht->cfg.size) that wi=
ll
>> +	 * give results between [0 and cfg.size-1] and same hash distribut=
ion,
>> +	 * but using a multiply, less expensive than a divide
>> +	 */
>> +	return ((u64)hash * ht->cfg.size) >> 32;
>=20
> Are we sure of the same hash distribution? Probably I miss something,
> but: if this 'hash' is well distributed on 32 bits, and ht->cfg.size
> is smaller than 32 bits, e.g. 256 (8 bits), then this multiplication
> moves to the higher 32 of u64 only max. 8 bits of the most significan=
t
> byte, and the other three bytes are never used, while division is
> always affected by all four bytes...

Not sure what you are saying... but if size=3D256, then, yes, we want a=
 final=20
result between 0 and 255, so three bytes are nul.


'size' is the size of hashtable, its not a random 32bits value :)

-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
