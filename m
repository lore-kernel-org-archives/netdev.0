From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Wed, 25 Feb 2015 23:15:14 +0200
Message-ID: <CAHsH6GtW1d9PvaOuTPxWqK_dWVZHxY7j7qgSJ8sChYsVYFj2UQ@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
	<20150223.164801.842537100812023841.davem@davemloft.net>
	<CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
	<CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
	<1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
	<1424788868.5565.81.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHsH6GuJENHse1EJXCzsEqcdCcJ=1xcPYpBO+e7fphxtRU8FyQ@mail.gmail.com>
	<CA+FuTScV8AgEumMsPnVVmRkYKjbJYLigAqqhrgzx9DDsXDz=2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:39470 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbbBYVPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 16:15:15 -0500
Received: by ykbq200 with SMTP id q200so2156013ykb.6
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 13:15:14 -0800 (PST)
In-Reply-To: <CA+FuTScV8AgEumMsPnVVmRkYKjbJYLigAqqhrgzx9DDsXDz=2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 10:49 PM, Willem de Bruijn <willemb@google.com> wrote:
>>> We have to be a bit creative/hacky to keep skb size small.
>>>
>>
>> I agree. I don't think these feature deserve an skb size increase, so
>> some hackery is required.
>>
>> Though, as skb->cb[] is somewhat 'owned' by the protocol families on
>> socket enqueue
>> I tend to find aliasing skb->priority with skb->dropcount "a lesser
>> evil" as compared with
>> partitioning the skb->cb[] space.
>
> Please consider another field than priority. There are use
> cases that want to receive priority, similar to reading mark.
>
> Indeed, I have a draft packet auxdata patch for one user who wants
> to see the iptables changes (and infer tc effects) on egress packets.
> Fwiw, that patch also exposes mark, and runs into exactly this issue
> that you're fixing, so thanks :)
>
> Fields that are consistently NULL on enqueue, such as the dev field
> that Eric proposed, do not have this drawback.

Thanks! I was wondering whether someone would want to fetch skb->priority.

I had already conceded that aliasing skb->priority won't hold.

I plan to submit a patch series for moving skb->dropcount to skb->cb[].
Following that I will re-submit the patch for fetching skb->mark in auxdata.
