From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Tue, 24 Feb 2015 08:58:52 +0200
Message-ID: <CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
	<20150223.164801.842537100812023841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:45806 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbbBXG6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 01:58:53 -0500
Received: by ykr200 with SMTP id 200so1749939ykr.12
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 22:58:52 -0800 (PST)
In-Reply-To: <20150223.164801.842537100812023841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2015 at 11:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Date: Mon, 23 Feb 2015 20:56:33 +0200
>
>> May I suggest to unalias 'mark' out of the union?
>
> Only in exchange for finding a way to remove completely another object
> of the same size from sk_buff.
>
> I refuse to let it grow any more, it's already way too big.

I agree that aliasing skb->priority with skb->dropcount and
skb->reserved_tailroom is
less than optimal.

I can suggest an alternative patch following Eric Dumazet's suggestion in which
skb->dropcount is removed and skb->cb[] is used instead for keeping dropcount.

That would require protocol family implementations to access skb->cb[]
via a common
accessor or use a common offset #define from the start of skb->cb[].

Eyal.
