From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Wed, 25 Feb 2015 15:49:40 -0500
Message-ID: <CA+FuTScV8AgEumMsPnVVmRkYKjbJYLigAqqhrgzx9DDsXDz=2w@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
 <1424713924-6821-4-git-send-email-eyal.birger@gmail.com> <20150223205633.7fbd08d4@halley>
 <20150223.164801.842537100812023841.davem@davemloft.net> <CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
 <CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
 <1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
 <1424788868.5565.81.camel@edumazet-glaptop2.roam.corp.google.com> <CAHsH6GuJENHse1EJXCzsEqcdCcJ=1xcPYpBO+e7fphxtRU8FyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:39455 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323AbbBYUuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 15:50:12 -0500
Received: by mail-ob0-f177.google.com with SMTP id wp18so6385724obc.8
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 12:50:12 -0800 (PST)
In-Reply-To: <CAHsH6GuJENHse1EJXCzsEqcdCcJ=1xcPYpBO+e7fphxtRU8FyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> We have to be a bit creative/hacky to keep skb size small.
>>
>
> I agree. I don't think these feature deserve an skb size increase, so
> some hackery is required.
>
> Though, as skb->cb[] is somewhat 'owned' by the protocol families on
> socket enqueue
> I tend to find aliasing skb->priority with skb->dropcount "a lesser
> evil" as compared with
> partitioning the skb->cb[] space.

Please consider another field than priority. There are use
cases that want to receive priority, similar to reading mark.

Indeed, I have a draft packet auxdata patch for one user who wants
to see the iptables changes (and infer tc effects) on egress packets.
Fwiw, that patch also exposes mark, and runs into exactly this issue
that you're fixing, so thanks :)

Fields that are consistently NULL on enqueue, such as the dev field
that Eric proposed, do not have this drawback.
