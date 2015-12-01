From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [RFCv3 bluetooth-next 3/4] ipv6: add ipv6_addr_prefix_copy
Date: Tue, 1 Dec 2015 20:17:19 +0900
Message-ID: <565D81BF.3080608@miraclelinux.com>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-4-git-send-email-alex.aring@gmail.com>
 <1448967386.3315997.454536553.3B344491@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Alexander Aring <alex.aring@gmail.com>,
	hideaki.yoshifuji@miraclelinux.com, kernel@pengutronix.de,
	mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35584 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101AbbLALRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 06:17:25 -0500
Received: by pacej9 with SMTP id ej9so2588650pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 03:17:25 -0800 (PST)
In-Reply-To: <1448967386.3315997.454536553.3B344491@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> 
> 
> On Sun, Nov 29, 2015, at 12:34, Alexander Aring wrote:
>> This patch adds a static inline function ipv6_addr_prefix_copy which
>> copies a ipv6 address prefix(argument pfx) into the ipv6 address prefix.
>> The prefix len is given by plen as bits. This function mainly based on
>> ipv6_addr_prefix which copies one address prefix from address into a new
>> ipv6 address destination and zero all other address bits.
>>
>> The difference is that ipv6_addr_prefix_copy don't get a prefix from an
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
>>  include/net/ipv6.h | 15 +++++++++++++++
>>  1 file changed, 15 insertions(+)
>>
>> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
>> index e1a10b0..cd3881e6 100644
>> --- a/include/net/ipv6.h
>> +++ b/include/net/ipv6.h
>> @@ -382,6 +382,21 @@ static inline void ipv6_addr_prefix(struct in6_addr
>> *pfx,
>>  		pfx->s6_addr[o] = addr->s6_addr[o] & (0xff00 >> b);
>>  }
>>  
>> +static inline void ipv6_addr_prefix_copy(struct in6_addr *addr,
>> +                                        const struct in6_addr *pfx,
>> +                                        int plen)
>> +{
>> +       /* caller must guarantee 0 <= plen <= 128 */
>> +       int o = plen >> 3,
>> +           b = plen & 0x7;
>> +
>> +       memcpy(addr->s6_addr, pfx, o);
>> +       if (b != 0) {
>> +               addr->s6_addr[o] &= ~(0xff00 >> b);
>> +               addr->s6_addr[o] |= (pfx->s6_addr[o] & (0xff00 >> b));
>> +       }
>> +}
>> +
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
ミラクル・リナックス株式会社 技術本部 サポート部
