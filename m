From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Tue, 24 Feb 2015 06:25:49 -0800
Message-ID: <1424787949.5565.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	 <1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	 <20150223205633.7fbd08d4@halley>
	 <20150223.164801.842537100812023841.davem@davemloft.net>
	 <CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
	 <CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
	 <1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:45477 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbbBXOZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 09:25:51 -0500
Received: by iecat20 with SMTP id at20so32255445iec.12
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 06:25:50 -0800 (PST)
In-Reply-To: <CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-24 at 16:07 +0200, Eyal Birger wrote:

> > rxpc is buggy right now anyway, as it reads skb->mark _and_ uses
> > sock_recv_ts_and_drops(), so skb->mark value is pretty much void.
> >
> 
> Yes, but it does not seem to use sock_queue_rcv_skb() which sets skb->dropcount.

Well, SO_RXQ_OVFL is broken for these sockets, as we'll report a
dropcount if skb->mark was set.
