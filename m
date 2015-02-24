From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Tue, 24 Feb 2015 12:10:40 +0200
Message-ID: <CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
	<20150223.164801.842537100812023841.davem@davemloft.net>
	<CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:44944 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbBXKKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 05:10:41 -0500
Received: by yhaf73 with SMTP id f73so13638209yha.11
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 02:10:41 -0800 (PST)
In-Reply-To: <CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 8:58 AM, Eyal Birger <eyal.birger@gmail.com> wrote:
> On Mon, Feb 23, 2015 at 11:48 PM, David Miller <davem@davemloft.net> wrote:
>> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>> Date: Mon, 23 Feb 2015 20:56:33 +0200
>>
>>> May I suggest to unalias 'mark' out of the union?
>>
>> Only in exchange for finding a way to remove completely another object
>> of the same size from sk_buff.
>>
>> I refuse to let it grow any more, it's already way too big.
>
> I agree that aliasing skb->priority with skb->dropcount and
> skb->reserved_tailroom is
> less than optimal.
>
> I can suggest an alternative patch following Eric Dumazet's suggestion in which
> skb->dropcount is removed and skb->cb[] is used instead for keeping dropcount.
>
> That would require protocol family implementations to access skb->cb[]
> via a common
> accessor or use a common offset #define from the start of skb->cb[].
>

Well, gave it a shot... it looks like several protocol families
(packet, rxrpc, bluetooth) do not
have room in skb->cb[] for the dropcount - at least on my 64 bit machine.
