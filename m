From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes only
 padding
Date: Sat, 7 Sep 2013 17:46:02 +0200
Message-ID: <20130907154602.GA1442@minipsycho.orion>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
 <alpine.LNX.2.00.1309071427120.1262@heraclitus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eldad Zack <eldad@fogrefinery.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:35663 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3IGPqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 11:46:08 -0400
Received: by mail-ea0-f175.google.com with SMTP id m14so2194849eaj.6
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 08:46:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1309071427120.1262@heraclitus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 07, 2013 at 02:31:36PM CEST, eldad@fogrefinery.com wrote:
>
>Hi Jiri,
>
>On Fri, 6 Sep 2013, Jiri Pirko wrote:
>
>> In rfc4942 and rfc2460 I cannot find anything which would implicate to
>> drop packets which have only padding in tlv.
>
>NAK from my side.
>Please read RFC4942 2.1.9.5 "Misuse of Pad1 and PadN Options".

I did.

>
>While it doesn't specifically discusses this corner case, you can 
>understand from "There is no legitimate reason for padding beyond the 
>next eight octet..." that there's also no legitimate reason for an 
>option header containing only padding.

Okay. I'm glad you agree with me and that we both understand the rfc the
same way. And since the rfc does not say that "here's no legitimate
reason for an option header containing only padding", this should be
possible. I say we respect rfc and do not add stronger restrictions than
it dictates. No need for them.

>I can't imagine a sane use-case for this.

rfcs are not about sanity...

>
>> Current behaviour breaks TAHI Test v6LC.1.2.6.
>
>I'm not familiar with this, but IMHO the test should be reversed :)
>
>Cheers,
>Eldad
>
>> 
>> Problem was intruduced in:
>> 9b905fe6843 "ipv6/exthdrs: strict Pad1 and PadN check"
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/ipv6/exthdrs.c | 6 ------
>>  1 file changed, 6 deletions(-)
>> 
>> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
>> index 07a7d65..8d67900 100644
>> --- a/net/ipv6/exthdrs.c
>> +++ b/net/ipv6/exthdrs.c
>> @@ -162,12 +162,6 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
>>  		off += optlen;
>>  		len -= optlen;
>>  	}
>> -	/* This case will not be caught by above check since its padding
>> -	 * length is smaller than 7:
>> -	 * 1 byte NH + 1 byte Length + 6 bytes Padding
>> -	 */
>> -	if ((padlen == 6) && ((off - skb_network_header_len(skb)) == 8))
>> -		goto bad;
>>  
>>  	if (len == 0)
>>  		return true;
>> -- 
>> 1.8.3.1
>> 
