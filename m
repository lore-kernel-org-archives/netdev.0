From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v5 5/6] 6lowpan: Use netdev addr_len to determine lladdr
 len
Date: Mon, 27 Feb 2017 08:24:33 +0100
Message-ID: <4781629d-7a02-b511-7591-50a127c29f50@pengutronix.de>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
 <20170224121440.32269-6-luiz.dentz@gmail.com>
 <39321f06-c013-1e8f-efd1-2e230659535b@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
        linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <39321f06-c013-1e8f-efd1-2e230659535b-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

H

On 02/27/2017 08:13 AM, Alexander Aring wrote:
> Hi,
> 
> On 02/24/2017 01:14 PM, Luiz Augusto von Dentz wrote:
>> From: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>>
>> This allow technologies such as Bluetooth to use its native lladdr which
>> is eui48 instead of eui64 which was expected by functions like
>> lowpan_header_decompress and lowpan_header_compress.
>>
>> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
>> ---
>>  include/net/6lowpan.h   | 19 +++++++++++++++++++
>>  net/6lowpan/iphc.c      | 49 ++++++++++++++++++++++++++++++++++++++-----------
>>  net/bluetooth/6lowpan.c | 42 ++++++------------------------------------
>>  3 files changed, 63 insertions(+), 47 deletions(-)
>>
>> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
>> index 5ab4c99..c5792cb 100644
>> --- a/include/net/6lowpan.h
>> +++ b/include/net/6lowpan.h
>> @@ -198,6 +198,25 @@ static inline void lowpan_iphc_uncompress_eui64_lladdr(struct in6_addr *ipaddr,
>>  	ipaddr->s6_addr[8] ^= 0x02;
>>  }
>>  
>> +static inline void lowpan_iphc_uncompress_eui48_lladdr(struct in6_addr *ipaddr,
>> +						       const void *lladdr)
>> +{
>> +	/* fe:80::XXXX:XXff:feXX:XXXX
>> +	 *        \_________________/
>> +	 *              hwaddr
>> +	 */
>> +	ipaddr->s6_addr[0] = 0xFE;
>> +	ipaddr->s6_addr[1] = 0x80;
>> +	memcpy(&ipaddr->s6_addr[8], lladdr, 3);
>> +	ipaddr->s6_addr[11] = 0xFF;
>> +	ipaddr->s6_addr[12] = 0xFE;
>> +	memcpy(&ipaddr->s6_addr[13], lladdr + 3, 3);
>> +	/* second bit-flip (Universe/Local)
>> +	 * is done according RFC2464
>> +	 */
>> +	ipaddr->s6_addr[8] ^= 0x02;
>> +}
>> +
> 
> same thing here. I think you don't need u/l bitflip here, you argumented
> already that IID is without it in another patch, or?
> 

ahhh, got it. You just moved the function into the header and patch 6/6
will remove the u/l handling. Sorry!

But then still patch 4/6 is wrong because it use u/l bitflip there.
(It's my patch yes :D, but I realized at first dev->addr_len should be 6
and not 8).

- Alex
