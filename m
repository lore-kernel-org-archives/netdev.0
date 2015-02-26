From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 7/7] net: move skb->dropcount to skb->cb[]
Date: Thu, 26 Feb 2015 20:52:30 +0200
Message-ID: <CAHsH6GunNMcG=bNGDG1NxHrGpX+h0PjSqMFFH-XQZvhLZFQosQ@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-8-git-send-email-eyal.birger@gmail.com>
	<20150226104909.1f2c882d@halley>
	<CAHsH6GvEmkOZU=VngK9-yn_2ajNX2YU1aJ=qfuHby3=58r4dKw@mail.gmail.com>
	<CAHsH6Gs5JwRXgWGuC4fKaqPU3yb219z1q1K-cvn5Z6qjFOgo8A@mail.gmail.com>
	<20150226173218.7c6bb2d6@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:36817 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbbBZSwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 13:52:31 -0500
Received: by yhaf73 with SMTP id f73so5516096yha.3
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 10:52:30 -0800 (PST)
In-Reply-To: <20150226173218.7c6bb2d6@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 5:32 PM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> On Thu, 26 Feb 2015 12:48:14 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
>> After giving it some additional thought and research, I don't think
>> this is necessary.
>>
>> The sizeof operator on struct sock_skb_cb would give a padded result
>> which would take care of the structure alignment.
>>
>> This is under the assumption that skb->cb[] size is of a proper multiple (which
>> I think is rather safe).
>
> Yes, you are correct.
>
> With the assumption that skb->cb and 'cb' size are properly aligned and
> sized (compile time asserted, btw?), you can simply:
>
> struct your_thing {     // name it
>         u32 dropcount;
> };
>
> struct sock_skb_cb {
>         /* protocol families specifc CBs */
>         u8 pf_reserved[PAD];
>         struct your_thing sock_cb;
> };
>
> where:
>
> #define PAD (FIELD_SIZEOF(struct sk_buff, cb) - sizeof(struct your_thing))
>

struct sock_skb_cb as I see it represents the sock generic metadata
required in the skb->cb[] and its placement at the end of skb->cb[]
is an implementation detail - so it, in my view, is what you referred to as
"struct your_thing".

Coding-wise I would rather avoid the additional enclosing struct and stick
with the proposed implementation.

Eyal.
