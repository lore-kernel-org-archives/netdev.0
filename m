From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 2/7] net: bluetooth: compact struct bt_skb_cb by
 converting boolean fields to bit fields
Date: Thu, 26 Feb 2015 15:21:15 +0200
Message-ID: <CAHsH6GtLkHV7NgPapcD7SxZvCa=NdzSo41N7VBQLCFOVeKunLw@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-3-git-send-email-eyal.birger@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAEE8D0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"willemb@google.com" <willemb@google.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"shmulik.ladkani@gmail.com" <shmulik.ladkani@gmail.com>,
	"marcel@holtmann.org" <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:36089 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbbBZNVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 08:21:15 -0500
Received: by yhaf73 with SMTP id f73so4377513yha.3
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 05:21:15 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAEE8D0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Feb 26, 2015 at 1:31 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Eyal Birger
>> On 64 bit systems, struct bt_skb_cb size is padded by 6 bytes in order
>> to reach 8 byte alignment.
>> Convert boolean fields force_active, incoming and req_start to bit fields
>> in order to eliminate the padding.
> ...
>> +++ b/include/net/bluetooth/bluetooth.h
> ...
>>  struct bt_skb_cb {
>>       __u8 pkt_type;
>> -     __u8 incoming;
>>       __u16 opcode;
>>       __u16 expect;
>> -     __u8 force_active;
>> -     bool req_start;
>> +     __u8 force_active:1;
>> +     __u8 incoming:1;
>> +     __u8 req_start:1;
>>       u8 req_event;
>>       hci_req_complete_t req_complete;
>>       struct l2cap_chan *chan;
>
> You've generated some pad bytes, best to put everything on its natural alignment.
> The old version had req_complete at offset 9, the new one at offset 8.
> Not sure how this removes 6 bytes of pad.
>

Hmm, I tried different variations here. At a certain point, I had 6
bytes of padding.
Seems pahole is playing peekaboo on my holes :)

Anyway, since req_complete has to be pointer aligned, it does not
reside at offset 9,
but at offset 16, which creates a hole.

Thanks. I will update appropriately in v2.
