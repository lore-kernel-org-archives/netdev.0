From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Tue, 24 Feb 2015 05:18:35 -0800
Message-ID: <1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	 <1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	 <20150223205633.7fbd08d4@halley>
	 <20150223.164801.842537100812023841.davem@davemloft.net>
	 <CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
	 <CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35983 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbbBXNSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 08:18:38 -0500
Received: by ierx19 with SMTP id x19so31788882ier.3
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 05:18:37 -0800 (PST)
In-Reply-To: <CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-24 at 12:10 +0200, Eyal Birger wrote:

> 
> Well, gave it a shot... it looks like several protocol families
> (packet, rxrpc, bluetooth) do not
> have room in skb->cb[] for the dropcount - at least on my 64 bit machine.

No idea how you took a look ?

sizeof(struct packet_skb_cb) == 24  : We have plenty of room ?


bluetooth : Whole struct rxrpc_skb_priv is not used when packet is
stored in receive queue.

We only need bt_cb(skb)->psm & bt_cb(skb)->bdaddr according to
l2cap_skb_msg_name()

An union will be possible.

rxpc is buggy right now anyway, as it reads skb->mark _and_ uses
sock_recv_ts_and_drops(), so skb->mark value is pretty much void.

Note that resend_at field could probably converted into u32. tcp stack
uses same (u32)jiffies trick (tcp_time_stamp)


I never said it was going to be easy ;)
