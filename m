From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: SNAT --random & fully is not actually random for ips
Date: Mon, 28 Nov 2016 13:35:33 +0200
Message-ID: <b4333f580bdb9ca2ede6269a9de3135c@nuclearcat.com>
References: <97a6a1c557f0f1e6d55d8d09b326f8b1@nuclearcat.com>
 <20161128110651.GA1024@salvia>
 <fb3151804cc3b2c57e69d1059b3417ee@nuclearcat.com>
 <20161128112955.GA1691@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161128112955.GA1691@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-11-28 13:29, Pablo Neira Ayuso wrote:
> On Mon, Nov 28, 2016 at 01:12:07PM +0200, Denys Fedoryshchenko wrote:
>> On 2016-11-28 13:06, Pablo Neira Ayuso wrote:
>> >Why does your patch reverts NF_NAT_RANGE_PROTO_RANDOM_FULLY?
>> 
>> Ops, sorry i just did mistake with files, actually it is in reverse ( 
>> did
>> this patch, and it worked properly with it, with random source ip).
> 
> Oh, I see 8)
> 
>> --- nf_nat_core.c	2016-11-21 09:11:59.000000000 +0000
>> +++ nf_nat_core.c.new	2016-11-28 09:55:54.000000000 +0000
>> @@ -282,9 +282,13 @@
>>  	 * client coming from the same IP (some Internet Banking sites
>>  	 * like this), even across reboots.
>>  	 */
>> -	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / 
>> sizeof(u32),
>> +	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY) {
>> +	    j = prandom_u32();
>> +	} else {
>> +	    j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / 
>> sizeof(u32),
>>  		   range->flags & NF_NAT_RANGE_PERSISTENT ?
>>  			0 : (__force u32)tuple->dst.u3.all[max] ^ zone->id);
>> +	}
>> 
>>  	full_range = false;
>>  	for (i = 0; i <= max; i++) {
>> 
>> This is current situation, RANDOM_FULLY actually does prandom_u32 for 
>> source
>> port only, but not for IP.
>> IP kept as persistent and kind of predictable, because hash function 
>> based
>> on source ip.
>> 
>> Sure i did tried to specify any combination of flags, but looking to
>> "find_best_ips_proto" function, it wont have any effect.
> 
> IIRC the original intention on random-fully was to cover only ports.
> Did you interpret from git history otherwise? Otherwise, safe
> procedure is to add a new flag.
No, seems i didnt read man page well, sorry.
I will check it, maybe will try to add new option and submit a patch, 
still studying impact on "balancing" with this change, seems it works 
great.
But not really sure such thing needed for someone else, actually some 
might have privacy concerns as well, and can use such option for 
privacy.
