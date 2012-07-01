From: Hannes Frederic Sowa <hannes@mailcolloid.de>
Subject: Re: [PATCH V3 2/2] bonding support for IPv6 transmit hashing
Date: Sun, 1 Jul 2012 05:57:57 +0200
Message-ID: <CAMEyesDY898iOUmtzPqp1ZGckDwNVWdP9AhZemLV8a0v+eJ9_Q@mail.gmail.com>
References: <4FEE99EE.2000001@8192.net>
	<CAMEyesBOj2cd6sAmowjk1vATrMjxHreeJoDEdksVwENkEWWqLQ@mail.gmail.com>
	<4FEF55A7.6070502@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: John <linux@8192.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:43177 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737Ab2GAD57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 23:57:59 -0400
Received: by lbbgm6 with SMTP id gm6so6315904lbb.19
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 20:57:58 -0700 (PDT)
In-Reply-To: <4FEF55A7.6070502@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 30, 2012 at 9:38 PM, John <linux@8192.net> wrote:
> On 6/30/2012 4:59 AM, Hannes Frederic Sowa wrote:
>> On Sat, Jun 30, 2012 at 8:17 AM, John <linux@8192.net> wrote:
>>>
>>> diff --git a/Documentation/networking/bonding.txt
>>> b/Documentation/networking/bonding.txt
>>> index bfea8a3..5db14fe 100644
>>> --- a/Documentation/networking/bonding.txt
>>> +++ b/Documentation/networking/bonding.txt
>>> @@ -752,12 +752,22 @@ xmit_hash_policy
>>>                  protocol information to generate the hash.
>>>
>>>                  Uses XOR of hardware MAC addresses and IP addresses to
>>> -               generate the hash.  The formula is
>>> +               generate the hash.  The IPv4 formula is
>>>
>>>                  (((source IP XOR dest IP) AND 0xffff) XOR
>>>                          ( source MAC XOR destination MAC ))
>>>                                  modulo slave count
>>>
>>> +               The IPv6 forumla is
>>> +
>>> +               iphash =
>>> +                       (source ip quad 2 XOR dest IP quad 2) XOR
>>> +                       (source ip quad 3 XOR dest IP quad 3) XOR
>>> +                       (source ip quad 4 XOR dest IP quad 4)
>>> +
>>> +               ((iphash >> 16) XOR (iphash >> 8) XOR iphash)
>>> +                       modulo slave count
>>> +
>>
>>
>> Wouldn't it be beneficial to include the ipv6 flow label in the hash
>> calculation?
>
> Hannes,
>
> In all of the traffic I inspected I don't believe I saw a single flow label
> set. Even if it were set 100% of the time by Linux, any packets routed or
> bridged from another operating system wouldn't see any benefit. The current
> algorithm distributes the traffic very well, I don't believe adding the flow
> label would be beneficial even if it were set more frequently.
>
> If you feel strongly about its inclusion, though, I am willing to
> reconsider.

It would definitely help to load balance tunnelled traffic over a
bonded interface. But as I currently don't use such a setup, I don't
have a strong opinion on that.

Greetings,

  Hannes
