From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Tue, 24 Feb 2015 16:41:16 +0200
Message-ID: <13A594FB-4232-4AC0-BADE-778B5D452633@gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com> <1424713924-6821-4-git-send-email-eyal.birger@gmail.com> <20150223205633.7fbd08d4@halley> <20150223.164801.842537100812023841.davem@davemloft.net> <CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com> <CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com> <1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com> <CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com> <1424787949.5565.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:41820 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbbBXOlV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 09:41:21 -0500
Received: by wevm14 with SMTP id m14so25581702wev.8
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 06:41:19 -0800 (PST)
In-Reply-To: <1424787949.5565.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 24 Feb 2015, at 16:25, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> On Tue, 2015-02-24 at 16:07 +0200, Eyal Birger wrote:
> 
>>> rxpc is buggy right now anyway, as it reads skb->mark _and_ uses
>>> sock_recv_ts_and_drops(), so skb->mark value is pretty much void.
>> 
>> Yes, but it does not seem to use sock_queue_rcv_skb() which sets skb->dropcount.
> 
> Well, SO_RXQ_OVFL is broken for these sockets, as we'll report a
> dropcount if skb->mark was set.
> 
> 
Right. That feature seems broken.

Fixing it would mean either 
avoiding the use of skb->mark in 
rxrpc or aliasing dropcount with 
something else.

I am also not sure what should be the
semantics of SO_RCVMARK on these
sockets.
