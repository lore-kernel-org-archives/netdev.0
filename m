From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [RFCv2 bluetooth-next 2/3] ipv6: add ipv6_addr_prefix_cpy
Date: Wed, 25 Nov 2015 17:42:43 +0100
Message-ID: <5655E503.8060107@osg.samsung.com>
References: <1447799594-6050-1-git-send-email-alex.aring@gmail.com>
 <1447799594-6050-3-git-send-email-alex.aring@gmail.com>
 <564C8336.7000100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexander Aring <alex.aring@gmail.com>,
	linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:55447 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051AbbKYQms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 11:42:48 -0500
In-Reply-To: <564C8336.7000100@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18/11/15 14:55, Sergei Shtylyov wrote:
> Hello.
>
> On 11/18/2015 1:33 AM, Alexander Aring wrote:
>
>> This patch adds a static inline function ipv6_addr_prefix_cpy which
>
>    I suggest not to reduce "copy".

Agreed. Not worth saving one character here.

>
>> copies a ipv6 address prefix(argument pfx) into the ipv6 address prefix.
>> The prefix len is given by plen as bits. This function mainly based on
>> ipv6_addr_prefix which copies one address prefix from address into a new
>> ipv6 address destination and zero all other address bits.
>>
>> The difference is that ipv6_addr_prefix_cpy don't get a prefix from an
>> ipv6 address, it sets a prefix to an ipv6 address with keeping other
>> address bits. The use case is for context based address compression
>> inside 6LoWPAN IPHC header which keeping ipv6 prefixes inside a context
>> table to lookup address-bits without sending them.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> Cc: James Morris <jmorris@namei.org>
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
>> ---
>>   include/net/ipv6.h | 15 +++++++++++++++
>>   1 file changed, 15 insertions(+)
>>
>> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
>> index e1a10b0..9d38fc2 100644
>> --- a/include/net/ipv6.h
>> +++ b/include/net/ipv6.h
>> @@ -382,6 +382,21 @@ static inline void ipv6_addr_prefix(struct 
>> in6_addr *pfx,
>>           pfx->s6_addr[o] = addr->s6_addr[o] & (0xff00 >> b);
>>   }
>>
>> +static inline void ipv6_addr_prefix_cpy(struct in6_addr *addr,
>> +                    const struct in6_addr *pfx,
>> +                    int plen)
>> +{
>> +    /* caller must guarantee 0 <= plen <= 128 */
>> +    int o = plen >> 3,
>> +        b = plen & 0x7;
>
>    Unusual declaration style, why not just have *int* on both lines?
>

He took that from ipv6_addr_prefix() defined above it. I would also 
prefer a second line with int for the second declaration. But as he 
followed the coding style already around I think both way are fine.

regards
Stefan Schmidt
