From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Tue, 24 Feb 2015 17:24:39 +0200
Message-ID: <CAHsH6GuJENHse1EJXCzsEqcdCcJ=1xcPYpBO+e7fphxtRU8FyQ@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
	<20150223.164801.842537100812023841.davem@davemloft.net>
	<CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
	<CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
	<1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
	<1424788868.5565.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:46006 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbbBXQ5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 11:57:22 -0500
Received: by yhai57 with SMTP id i57so14594541yha.12
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 08:57:21 -0800 (PST)
In-Reply-To: <1424788868.5565.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 4:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-02-24 at 16:07 +0200, Eyal Birger wrote:
>
>> Well, I took a look, then I tried :)
>>
>> It breaks in packet_rcv() in a BUILD_BUG_ON() assertion. The asserted size is:
>>
>> sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8
>>
>> This was introduced in ffbc61117d32dc4e768 ("[PACKET]: Fix skb->cb
>> clobbering between aux and sockaddr")
>> It requires the ability to store the maximal possible address length (32).
>
> OK this might require to move origlen elsewhere in skb.
>
> skb->dev for example is set to NULL, same for skb dst.
>
> We have to be a bit creative/hacky to keep skb size small.
>

I agree. I don't think these feature deserve an skb size increase, so
some hackery is required.

Though, as skb->cb[] is somewhat 'owned' by the protocol families on
socket enqueue
I tend to find aliasing skb->priority with skb->dropcount "a lesser
evil" as compared with
partitioning the skb->cb[] space.
