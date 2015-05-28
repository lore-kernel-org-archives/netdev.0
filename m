From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next 05/11] net: Add full IPv6 addresses to flow_keys
Date: Thu, 28 May 2015 15:38:14 -0700
Message-ID: <CALx6S36WsA_GgEsWo96BPtJm95knCnusNOw_vsUOhQZnC5BxQw@mail.gmail.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
	<1432837148-1359931-6-git-send-email-tom@herbertland.com>
	<1432849496.7456.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33673 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503AbbE1WiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 18:38:14 -0400
Received: by iebgx4 with SMTP id gx4so49702891ieb.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 15:38:14 -0700 (PDT)
In-Reply-To: <1432849496.7456.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 2:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-05-28 at 11:19 -0700, Tom Herbert wrote:
>
>> @@ -566,11 +640,15 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
>>       },
>>       {
>>               .key_id = FLOW_DISSECTOR_KEY_IPV4_ADDRS,
>> -             .offset = offsetof(struct flow_keys, addrs),
>> +             .offset = offsetof(struct flow_keys, addrs.v4addrs),
>> +     },
>> +     {
>> +             .key_id = FLOW_DISSECTOR_KEY_IPV6_ADDRS,
>> +             .offset = offsetof(struct flow_keys, addrs.v6addrs),
>>       },
>>       {
>>               .key_id = FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
>> -             .offset = offsetof(struct flow_keys, addrs),
>> +             .offset = offsetof(struct flow_keys, addrs.v4addrs),
>
> Shouldn't it be offsetof(struct flow_keys, addrs.v6addrs), ?
>
This is to hash 128 bit IP addresses into 32 bit values which fit in
the v4addrs area. This completely goes away in 07 patch in this set.

>
>
