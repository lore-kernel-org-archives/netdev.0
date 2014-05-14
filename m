From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 2/2] net: systemport: pad packets to a minimum
 of 64 bytes
Date: Wed, 14 May 2014 09:09:05 -0700
Message-ID: <CAGVrzcb8cOsfR0x7aiEmG1v1Bb067d-_amYQ4X4uqQp62q-q5Q@mail.gmail.com>
References: <1399666599-19398-1-git-send-email-f.fainelli@gmail.com>
 <1399666599-19398-3-git-send-email-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F7116C2@AcuExch.aculab.com>
 <CAGVrzcadcBzoLL9sxnuZ-rszpO-h4BircuWxNr4a7oFHbKxtXA@mail.gmail.com>
 <CAGVrzcYKVm8Pps_DHrXmZ6wd6d6A3k7FjkEn9sVDo1PwA1fZcw@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D172442ED@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35881 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272AbaENQJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 12:09:46 -0400
Received: by mail-qg0-f45.google.com with SMTP id z60so3193952qgd.32
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 09:09:45 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D172442ED@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-14 1:51 GMT-07:00 David Laight <David.Laight@aculab.com>:
> From: Florian Fainelli
> ...
>> >>> +     if (skb_padto(skb, 64)) {
>> >>
>> >> Shouldn't that be 60?
>> >
>> > It should, absolutely, and that is ETH_ZLEN. Thanks!
>>
>> In fact, no, despite the Ethernet MAC appending the CRC, the minimum
>> packet length from the DMA perspective really needs to be 64, as the
>> hardware inserted CRC is not accounted for to generate the End of
>> Packet signal. That just translates into ETH_ZLEN + ETH_FCS_LEN
>> anyway.
>
> Hmmm.... That really doesn't sound right.
> The CRC can't be replacing the last 4 bytes of the skb - otherwise
> longer packets would be corrupted.
> So I'm sure that you are padding frames to 68 bytes.

Yes that's what I am doing. I was confused because I enabled the
switch tagging, which inserts a 4bytes tag between the Ethernet SA and
the Ethertype field. That specific switch tag length is not taken into
account by the switch to determine if a packet is runt, because the
tag is extracted before the packet enters the parsing logic. The
minimum frame length really needs to be 64 bytes with the FCS, but
without the switch tag inserted, so if we want to be safe, regardless
of the switch tag being inserted or not, the minimum frame length
needs to be 68 bytes with the FCS.

> While a typical IP implementation probably ignores pad bytes after
> any length frame, other protocols will only expect padding on short
> frames - and then only to the minimum frame length.
>
>         David
>



-- 
Florian
