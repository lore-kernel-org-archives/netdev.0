From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net v3 3/5] packet: only allow extra vlan len on ethernet devices
Date: Wed, 11 Nov 2015 18:11:51 -0500
Message-ID: <CA+FuTSdN3obhK7haXXbD=0Rj5UVE4tH6UpU8rEqi6TmvL1RrzA@mail.gmail.com>
References: <cover.1447278504.git.daniel@iogearbox.net> <45cbb079a6f1c88aff9da37198c8f8bb0414aefd.1447278504.git.daniel@iogearbox.net>
 <CA+FuTSeg9tyi+yd+2LuuzPcHs=H4NkPQXqEb+yrR9tQOKqim3A@mail.gmail.com> <5643CA3E.50703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:35781 "EHLO
	mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbbKKXMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 18:12:23 -0500
Received: by vkas68 with SMTP id s68so528561vka.2
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 15:12:22 -0800 (PST)
Received: from mail-vk0-f49.google.com (mail-vk0-f49.google.com. [209.85.213.49])
        by smtp.gmail.com with ESMTPSA id o138sm159354vkd.24.2015.11.11.15.12.21
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 15:12:21 -0800 (PST)
Received: by vkbs1 with SMTP id s1so525360vkb.3
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 15:12:21 -0800 (PST)
In-Reply-To: <5643CA3E.50703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 6:07 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 11/11/2015 11:55 PM, Willem de Bruijn wrote:
>>
>> On Wed, Nov 11, 2015 at 5:25 PM, Daniel Borkmann <daniel@iogearbox.net>
>> wrote:
>
> ...
>>>
>>> +       if (!gso_type && (len > dev->mtu + reserve + extra_len) &&
>>> +           !packet_extra_vlan_len_allowed(dev, skb)) {
>>> +               err = -EMSGSIZE;
>>> +               goto out_free;
>>
>>
>> This nicely reuses the same code in three locations.
>>
>> If you end up having to send a v4, it would be nice to also fold the
>> repeated len check into the shared code. Variable reserve here is
>> just dev->hard_header_len. No need to spin a patch just for that
>> cleanup, though.
>
>
> Noted, I was also thinking for net-next to move the tpacket_snd() check
> into tpacket_fill_skb(), that would save us to do the likely(tp_len >= 0)
> check there. Can take care of both when net-next opens, I feared there
> would be critics that it's not ending up minimal enough otherwise. ;)

Fair point :)

>
> Thanks,
> Daniel
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
