From: John <linux@8192.net>
Subject: Re: [PATCH V3 2/2] bonding support for IPv6 transmit hashing
Date: Sat, 30 Jun 2012 12:38:15 -0700
Message-ID: <4FEF55A7.6070502@8192.net>
References: <4FEE99EE.2000001@8192.net> <CAMEyesBOj2cd6sAmowjk1vATrMjxHreeJoDEdksVwENkEWWqLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@mailcolloid.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp153.dfw.emailsrvr.com ([67.192.241.153]:33703 "EHLO
	smtp153.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab2F3TiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 15:38:12 -0400
In-Reply-To: <CAMEyesBOj2cd6sAmowjk1vATrMjxHreeJoDEdksVwENkEWWqLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/30/2012 4:59 AM, Hannes Frederic Sowa wrote:
> On Sat, Jun 30, 2012 at 8:17 AM, John <linux@8192.net> wrote:
>> diff --git a/Documentation/networking/bonding.txt
>> b/Documentation/networking/bonding.txt
>> index bfea8a3..5db14fe 100644
>> --- a/Documentation/networking/bonding.txt
>> +++ b/Documentation/networking/bonding.txt
>> @@ -752,12 +752,22 @@ xmit_hash_policy
>>                  protocol information to generate the hash.
>>
>>                  Uses XOR of hardware MAC addresses and IP addresses to
>> -               generate the hash.  The formula is
>> +               generate the hash.  The IPv4 formula is
>>
>>                  (((source IP XOR dest IP) AND 0xffff) XOR
>>                          ( source MAC XOR destination MAC ))
>>                                  modulo slave count
>>
>> +               The IPv6 forumla is
>> +
>> +               iphash =
>> +                       (source ip quad 2 XOR dest IP quad 2) XOR
>> +                       (source ip quad 3 XOR dest IP quad 3) XOR
>> +                       (source ip quad 4 XOR dest IP quad 4)
>> +
>> +               ((iphash >> 16) XOR (iphash >> 8) XOR iphash)
>> +                       modulo slave count
>> +
>
> Wouldn't it be beneficial to include the ipv6 flow label in the hash
> calculation?
>
> Greetings,
>
>    Hannes
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Hannes,

In all of the traffic I inspected I don't believe I saw a single flow 
label set. Even if it were set 100% of the time by Linux, any packets 
routed or bridged from another operating system wouldn't see any 
benefit. The current algorithm distributes the traffic very well, I 
don't believe adding the flow label would be beneficial even if it were 
set more frequently.

If you feel strongly about its inclusion, though, I am willing to 
reconsider.

John
