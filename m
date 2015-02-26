From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 2/7] net: bluetooth: compact struct bt_skb_cb by
 converting boolean fields to bit fields
Date: Thu, 26 Feb 2015 15:22:32 +0200
Message-ID: <CAHsH6GsMPoMKTF14uCLXWeqx=6o07egpHpBG4U07YNMiRpj8pA@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-3-git-send-email-eyal.birger@gmail.com>
	<20150226093041.5cac2141@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:33810 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932342AbbBZNWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 08:22:33 -0500
Received: by yhai57 with SMTP id i57so4388776yha.1
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 05:22:32 -0800 (PST)
In-Reply-To: <20150226093041.5cac2141@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 9:30 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> On Thu, 26 Feb 2015 04:10:07 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
>> @@ -277,11 +277,11 @@ typedef void (*hci_req_complete_t)(struct hci_dev *hdev, u8 status, u16 opcode);
>>
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
> There's a:
>     bt_cb(skb)->force_active = BT_POWER_FORCE_ACTIVE_ON;
> assignment in l2cap_core.c.
>
> No bluetooth expert, no idea if BT_POWER_FORCE_ACTIVE_ON is 1 by definition.
> If not, maybe prefer:
>     bt_cb(skb)->force_active = !!BT_POWER_FORCE_ACTIVE_ON
>

I think I can keep force_active as __u8.

Will update on v2.

Thanks!

> Besides that,
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
