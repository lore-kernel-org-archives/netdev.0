From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Mon, 21 Dec 2015 12:38:27 -0800
Message-ID: <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
References: <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151215174346.GA3187@1wt.eu>
	<1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151215194410.GB3187@1wt.eu>
	<1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151216073814.GA3373@1wt.eu>
	<20151216161514.GA3476@1wt.eu>
	<CAO5YkUSL=k3UxmuqkGN666YSvH-=UGKCZvRgqqBnnr1EPRqRtw@mail.gmail.com>
	<20151218185812.GD4448@1wt.eu>
	<1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151219070009.GA4634@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33038 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbLUUi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 15:38:27 -0500
Received: by mail-io0-f181.google.com with SMTP id 186so168650569iow.0
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 12:38:27 -0800 (PST)
In-Reply-To: <20151219070009.GA4634@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 11:00 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Fri, Dec 18, 2015 at 06:38:03PM -0800, Eric Dumazet wrote:
>> On Fri, 2015-12-18 at 19:58 +0100, Willy Tarreau wrote:
>> > Hi Josh,
>> >
>> > On Fri, Dec 18, 2015 at 08:33:45AM -0800, Josh Snyder wrote:
>> > > I was also puzzled that binding succeeded. Looking into the code paths
>> > > involved, in inet_csk_get_port, we quickly goto have_snum. From there, we end
>> > > up dropping into tb_found. Since !hlist_empty(&tb->owners), we end up checking
>> > > that (tb->fastreuseport > 0 && sk->sk_reuseport && uid_eq(tb->fastuid, uid)).
>> > > This test passes, so we goto success and bind.
>> > >
>> > > Crucially, we are checking the fastreuseport field on the inet_bind_bucket, and
>> > > not the sk_reuseport variable on the other sockets in the bucket. Since this
>> > > bit is set based on sk_reuseport at the time the first socket binds (see
>> > > tb_not_found), I can see no reason why sockets need to keep SO_REUSEPORT set
>> > > beyond initial binding.
>> > >
>> > > Given this, I believe Willy's patch elegantly solves the problem at hand.
>> >
>> > Great, thanks for your in-depth explanation.
>> >
>> > Eric, do you think that this patch may be acceptable material for next
>> > merge window (given that it's not a fix per-se) ? If so I'll resubmit
>> > later.
>>
>> I need to check with Craig Gallek, because he was about to upstream a
>> change to make SO_REUSEPORT more scalable & sexy (like having an [e]BPF
>> filter to perform the selection in an array of sockets)
>
> OK fine. Please note that I also considered using a new value instead of
> zero there but I preferred to avoid it since the man talked about zero/
> non-zero so I wanted to limit any API change. If Craig adds new values
> there then this is something we can reconsider.
>
Is there any reason why this turning off a soreuseport socket should
not apply to UDP also? (seems like we have a need to turn off RX but
not TX for a UDP socket).

Tom

> Have a nice week-end,
> Willy
>
